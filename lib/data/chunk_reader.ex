defmodule Bigtable.ChunkReader do
  @moduledoc """
  Reads chunks from `Google.Bigtable.V2.ReadRowsResponse` and parses them into complete cells grouped by rowkey.
  """

  use Agent, restart: :temporary

  defmodule ReadCell do
    @moduledoc """
    A finished cell produced by `Bigtable.ChunkReader`.
    """
    defstruct [
      :label,
      :row_key,
      :family_name,
      :qualifier,
      :timestamp,
      :value
    ]
  end

  defmodule ReaderState do
    @moduledoc false
    defstruct [
      :cur_key,
      :cur_label,
      :cur_fam,
      :cur_qual,
      :cur_val,
      :last_key,
      cur_row: %{},
      cur_ts: 0,
      state: :new_row
    ]
  end

  @typedoc """
  A map containging lists of `Bigtable.ChunkReader.ReadCell` keyed by row key.
  """
  @type chunk_reader_result :: %{optional(binary()) => [Bigtable.ChunkReader.ReadCell.t()]}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %ReaderState{}, [])
  end

  @doc """
  Opens a `Bigtable.ChunkReader`.
  """
  @spec open() :: :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def open() do
    DynamicSupervisor.start_child(__MODULE__.Supervisor, __MODULE__)
  end

  @doc """
  Closes a `Bigtable.ChunkReader` when provided its pid and returns the chunk_reader_result.
  """
  @spec close(pid()) :: {:ok, chunk_reader_result} | {:error, binary()}
  def close(pid) do
    GenServer.call(pid, :close)
  end

  @doc """
  Processes a `Google.Bigtable.V2.ReadRowsResponse.CellChunk` given a `Bigtable.ChunkReader` pid.
  """
  @spec process(pid(), Google.Bigtable.V2.ReadRowsResponse.CellChunk.t()) ::
          {:ok, chunk_reader_result} | {:error, binary()}
  def process(pid, cc) do
    GenServer.call(pid, {:process, cc})
  end

  @doc false
  def init(state) do
    {:ok, state}
  end

  @doc false
  def handle_call(:close, _from, cr) do
    if cr.state == :new_row do
      {:reply, {:ok, cr.cur_row}, cr}
    else
      {:reply, {:error, "invalid state for end of stream #{cr.state}"}, cr}
    end
  end

  @doc false
  def handle_call({:process, cc}, _from, cr) do
    case handle_state(cr.state, cr, cc) do
      {:error, _msg} = result ->
        {:reply, result, cr}

      next_state ->
        {:reply, {:ok, next_state.cur_row}, next_state}
    end
  end

  defp handle_state(:new_row, cr, cc) do
    with :ok <- validate_new_row(cr, cc) do
      to_merge = %{
        cur_key: cc.row_key,
        cur_fam: cc.family_name,
        cur_qual: cc.qualifier,
        cur_ts: cc.timestamp_micros
      }

      cr
      |> Map.merge(to_merge)
      |> handle_cell_value(cc)
    else
      e ->
        e
    end
  end

  defp handle_state(:cell_in_progress, cr, cc) do
    with :ok <- validate_cell_in_progress(cr, cc) do
      if reset_row?(cc) do
        reset_to_new_row(cr)
      else
        cr
        |> handle_cell_value(cc)
      end
    else
      e ->
        e
    end
  end

  defp handle_state(:row_in_progress, cr, cc) do
    with :ok <- validate_row_in_progress(cr, cc) do
      if reset_row?(cc) do
        reset_to_new_row(cr)
      else
        cr
        |> update_if_contains(cc, :family_name, :cur_fam)
        |> update_if_contains(cc, :qualifier, :cur_qual)
        |> update_if_contains(cc, :timestamp_micros, :cur_ts)
        |> handle_cell_value(cc)
      end
    else
      e ->
        e
    end
  end

  defp update_if_contains(cr, cc, cc_key, cr_key) do
    value = Map.get(cc, cc_key)

    if value != nil do
      Map.put(cr, cr_key, value)
    else
      cr
    end
  end

  defp validate_new_row(cr, cc) do
    cond do
      reset_row?(cc) ->
        {:error, "reset_row not allowed between rows"}

      !row_key?(cc) or !family?(cc) or !qualifier?(cc) ->
        {:error, "missing key field for new row #{inspect(cc)}"}

      cr.last_key != "" and cr.last_key >= cc.row_key ->
        {:error, "out of order row key: #{cr.last_key}, #{cc.row_key}"}

      true ->
        :ok
    end
  end

  defp validate_row_in_progress(cr, cc) do
    status = validate_row_status(cc)

    cond do
      status != :ok ->
        status

      row_key?(cc) and cc.row_key != cr.cur_key ->
        {:error, "received new row key #{cc.row_key} during existing row #{cr.cur_key}"}

      family?(cc) and !qualifier?(cc) ->
        {:error, "family name #{cc.family_name} specified without a qualifier"}

      true ->
        :ok
    end
  end

  defp validate_cell_in_progress(cr, cc) do
    status = validate_row_status(cc)

    cond do
      status != :ok ->
        status

      cr.cur_val == nil ->
        {:error, "no cached cell while CELL_IN_PROGRESS #{cc}"}

      !reset_row?(cc) and any_key_present?(cc) ->
        {:error, "cell key components found while CELL_IN_PROGRESS #{cc}"}

      true ->
        :ok
    end
  end

  defp validate_row_status(cc) do
    cond do
      reset_row?(cc) and (any_key_present?(cc) or value?(cc) or value_size?(cc) or labels?(cc)) ->
        {:error, "reset must not be specified with other fields #{inspect(cc)}"}

      commit_row?(cc) and value_size?(cc) ->
        {:error, "commit row found in between chunks in a cell"}

      true ->
        :ok
    end
  end

  defp handle_cell_value(cr, %{value_size: value_size} = cc) when value_size > 0 do
    next_value =
      if cr.cur_val == nil do
        <<>> <> cc.value
      else
        cr.cur_val <> cc.value
      end

    next_label =
      if has_property?(cr, :cur_label) do
        cr.cur_label
      else
        Map.get(cc, :labels, "")
      end

    Map.put(cr, :cur_val, next_value)
    |> Map.put(:cur_label, next_label)
    |> Map.put(:state, :cell_in_progress)
  end

  defp handle_cell_value(cr, cc) do
    next_value =
      if cr.cur_val == nil do
        cc.value
      else
        cr.cur_val <> cc.value
      end

    next_label =
      if has_property?(cr, :cur_label) do
        cr.cur_label
      else
        Map.get(cc, :labels, "")
      end

    Map.put(cr, :cur_val, next_value)
    |> Map.put(:cur_label, next_label)
    |> finish_cell(cc)
  end

  defp finish_cell(cr, cc) do
    label =
      case cr.cur_label do
        label when is_list(label) ->
          Enum.join(label, " ")

        label ->
          label
      end

    ri = %ReadCell{
      label: label,
      qualifier: cr.cur_qual,
      row_key: cr.cur_key,
      family_name: cr.cur_fam,
      timestamp: cr.cur_ts,
      value: cr.cur_val
    }

    next_row =
      Map.update(cr.cur_row, cr.cur_key, [ri], fn prev ->
        [ri | prev]
      end)

    to_merge =
      if commit_row?(cc) do
        %{
          last_key: cr.cur_key,
          state: :new_row
        }
      else
        %{
          state: :row_in_progress
        }
      end

    next_state =
      Map.merge(to_merge, %{
        cur_row: next_row,
        cur_label: nil,
        cur_val: nil
      })

    Map.merge(cr, next_state)
  end

  defp reset_to_new_row(cr) do
    Map.merge(cr, %{
      cur_key: nil,
      cur_fam: nil,
      cur_qual: nil,
      cur_val: nil,
      cur_row: %{},
      cur_ts: 0,
      state: :new_row
    })
  end

  defp any_key_present?(cc) do
    row_key?(cc) or family?(cc) or qualifier?(cc) or cc.timestamp_micros != 0
  end

  defp value?(cc), do: has_property?(cc, :value)
  defp value_size?(cc), do: cc.value_size > 0

  defp labels?(cc) do
    value = Map.get(cc, :labels)
    value != [] and value != nil and value != ""
  end

  defp row_key?(cc), do: has_property?(cc, :row_key)
  defp family?(cc), do: has_property?(cc, :family_name)
  defp qualifier?(cc), do: has_property?(cc, :qualifier)

  defp has_property?(cc, key) do
    val = Map.get(cc, key)
    val != nil and val != ""
  end

  defp reset_row?(cc), do: row_status(cc) == :reset_row
  defp commit_row?(cc), do: row_status(cc) == :commit_row

  defp row_status(cc) do
    case cc.row_status do
      {status, true} ->
        status

      _ ->
        nil
    end
  end
end

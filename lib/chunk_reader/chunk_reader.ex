defmodule Bigtable.ChunkReader do
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  use Agent, restart: :temporary

  defmodule ReadItem do
    defstruct [
      :label,
      :row_key,
      :qualifier,
      :timestamp,
      :value
    ]
  end

  defmodule ReaderState do
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

  def start_link(_) do
    Agent.start_link(fn -> %ReaderState{} end)
  end

  def open() do
    DynamicSupervisor.start_child(__MODULE__.Supervisor, __MODULE__)
  end

  def close(cr_pid) do
    %{state: state} = Agent.get(cr_pid, & &1)

    Agent.stop(cr_pid)

    if state == :new_row do
      :ok
    else
      {:error, "invalid state for end of stream #{state}"}
    end
  end

  def process(cr_pid, %CellChunk{} = cc) do
    cr = Agent.get(cr_pid, & &1)

    case handle_state(cr.state, cr, cc) do
      {:error, _} = result ->
        result

      next_state ->
        # next_state =
        #   if commit_row?(cc) do
        #     %ReaderState{
        #       last_key: last_row_key(cr)
        #     }
        #   else
        #     updated_state
        #   end

        Agent.update(cr_pid, fn _ -> next_state end)

        {:ok, next_state.cur_row}
    end
  end

  defp last_row_key(%{cur_row: cur_row}) do
    cells =
      Map.values(cur_row)
      |> List.flatten()

    if length(cells) > 0 do
      List.first(cells)
      |> Map.fetch!(:row_key)
    else
      ""
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
    row_status = validate_row_status(cc)

    cond do
      row_status(cc) != :ok ->
        row_status

      row_key?(cc) and cc.row_key != cr.cur_key ->
        {:error, "received new row key #{cc.row_key} during existing row #{cr.cur_key}"}

      family?(cc) and !qualifier?(cc) ->
        {:error, "family name #{cc.family_name} specified without a qualifier"}

      true ->
        :ok
    end
  end

  defp validate_cell_in_progress(cr, cc) do
    row_status = validate_row_status(cc)

    cond do
      row_status(cc) != :ok ->
        row_status

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
    |> Map.put(:state, :row_in_progress)
    |> finish_cell()
  end

  defp finish_cell(cr) do
    label =
      case cr.cur_label do
        label when is_list(label) ->
          Enum.join(label, " ")

        label ->
          label
      end

    ri = %ReadItem{
      label: label,
      qualifier: cr.cur_qual,
      row_key: cr.cur_key,
      timestamp: cr.cur_ts,
      value: cr.cur_val
    }

    next_row =
      Map.update(cr.cur_row, cr.cur_fam, [ri], fn prev ->
        [ri | prev]
      end)

    next_state = %{
      cur_row: next_row,
      cur_label: nil,
      cur_val: nil
    }

    Map.merge(cr, next_state)
  end

  defp any_key_present?(cc) do
    row_key?(cc) or family?(cc) or qualifier?(cc) or cc.timestamp_micros != 0
  end

  defp value?(cc), do: cc.value != nil
  defp value_size?(cc), do: cc.value_size > 0
  defp labels?(cc), do: has_property?(cc, :labels)
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

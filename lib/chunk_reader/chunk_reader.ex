defmodule Bigtable.ChunkReader do
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  use Agent, restart: :temporary

  defmodule ReadItem do
    defstruct [
      :row_key,
      :qualifier,
      :timestamp,
      :value
    ]
  end

  defmodule ReaderState do
    defstruct [
      :cur_key,
      :cur_fam,
      :cur_qual,
      :cur_ts,
      :cur_val,
      :last_key,
      state: :new_row,
      cur_row: %{}
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

    case cr.state do
      :new_row ->
        with :ok <- validate_new_row(cr, cc) do
          to_merge = %{
            cur_key: cc.row_key,
            cur_fam: cc.family_name,
            cur_qual: cc.qualifier,
            cur_ts: cc.timestamp_micros
          }

          next_state =
            cr
            |> Map.merge(to_merge)
            |> handle_cell_value(cc)

          Agent.update(cr_pid, fn _ -> next_state end)

          {:ok, next_state.cur_row}
        else
          {:error, msg} ->
            {:error, msg}
        end
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

  defp handle_cell_value(cr, %{value_size: value_size} = cc) when value_size > 0 do
  end

  defp handle_cell_value(cr, cc) do
    next_value =
      if cr.cur_val == nil do
        cc.value
      else
        cr.cur_val <> cc.value
      end

    Map.put(cr, :cur_val, next_value)
    |> finish_cell()
  end

  defp finish_cell(cr) do
    ri = %ReadItem{
      row_key: cr.cur_key,
      qualifier: cr.cur_qual,
      timestamp: cr.cur_ts,
      value: cr.cur_val
    }

    next_row =
      Map.update(cr.cur_row, cr.cur_fam, [ri], fn prev ->
        [ri | prev]
      end)

    next_state = %{
      cur_row: next_row,
      cur_val: nil,
      state: :row_in_progress
    }

    Map.merge(cr, next_state)
  end

  defp row_key?(cc), do: has_value?(cc, :row_key)
  defp family?(cc), do: has_value?(cc, :family_name)
  defp qualifier?(cc), do: has_value?(cc, :qualifier)

  defp has_value?(cc, key) do
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

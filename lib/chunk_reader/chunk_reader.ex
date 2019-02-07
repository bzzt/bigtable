defmodule Bigtable.ChunkReader do
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  use Agent, restart: :temporary

  defmodule ReaderState do
    defstruct [
      :cur_key,
      :cur_fam,
      :cur_qual,
      :cur_ts,
      :cur_val,
      :cur_row,
      :last_key,
      row: %{},
      state: :new_row
    ]
  end

  def start_link(_) do
    Agent.start_link(fn -> %ReaderState{} end)
  end

  def open() do
    DynamicSupervisor.start_child(__MODULE__.Supervisor, __MODULE__)
  end

  def close(reader) do
    Agent.stop(reader)
  end

  def process(reader, %CellChunk{} = cc) do
    cr = Agent.get(reader, & &1)

    case cr.state do
      :new_row ->
        with :ok <- validate_new_row(cr, cc) do
          {:ok, cc, cr}
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

  defp reset_row?(%CellChunk{} = cc), do: row_status(cc) == :reset_row
  defp row_key?(%CellChunk{} = cc), do: empty_value?(cc, :row_key)
  defp family?(%CellChunk{} = cc), do: empty_value?(cc, :family_name)
  defp qualifier?(%CellChunk{} = cc), do: empty_value?(cc, :qualifier)

  defp empty_value?(cc, key) do
    val = Map.get(cc, key)
    val == nil or val == ""
  end

  defp row_status(cc) do
    case cc.row_status do
      {status, true} ->
        status

      _ ->
        nil
    end
  end
end

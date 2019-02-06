defmodule Bigtable.Reader.ReadItem do
  defstruct [:row, :column, :timestamp, :value]
end

defmodule Bigtable.Reader.Chunk do
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  def reset_row?(%CellChunk{} = cc), do: row_status(cc) == :reset_row
  def row_key?(%CellChunk{} = cc), do: empty_value?(cc, :row_key)
  def family?(%CellChunk{} = cc), do: empty_value?(cc, :family_name)
  def qualifier?(%CellChunk{} = cc), do: empty_value?(cc, :qualifier)

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

defmodule Bigtable.Reader.ChunkReader do
  alias Bigtable.Reader.Chunk
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

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

  def process(%__MODULE__{} = cr, %CellChunk{} = cc) do
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

  defp validate_new_row(%__MODULE__{} = cr, %CellChunk{} = cc) do
    cond do
      Chunk.reset_row?(cc) ->
        {:error, "reset_row not allowed between rows"}

      !Chunk.row_key?(cc) or !Chunk.family?(cc) or !Chunk.qualifier?(cc) ->
        {:error, "missing key field for new row #{inspect(cc)}"}

      cr.last_key != "" and cr.last_key >= cc.row_key ->
        {:error, "out of order row key: #{cr.last_key}, #{cc.row_key}"}

      true ->
        :ok
    end
  end
end

defmodule Bigtable.Reader do
  def process()
end

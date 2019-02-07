defmodule TestResult do
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk
  defstruct rk: "", fm: "", qual: "", ts: 0, value: "", label: "", error: false

  def from_chunk(%CellChunk{} = cc) do
    %__MODULE__{
      rk: cc.row_key,
      fm: cc.family_name,
      qual: cc.qualifier,
      ts: cc.timestamp_micros,
      value: cc.value,
      label: cc.labels
    }
  end
end

defmodule GoogleAcceptanceTest do
  alias Bigtable.ChunkReader

  defmacro __using__(json: json) do
    File.read!(json)
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:tests)
    |> Enum.map(fn t ->
      quote do
        test unquote(t.name) do
          %{chunks: chunks, results: results} = unquote(Macro.escape(t))

          result = process_chunks(chunks)

          if results_error?(results) do
            assert result.error == true
          else
          end
        end
      end
    end)
  end
end

defmodule ReadRowsAcceptanceTest do
  alias Bigtable.ChunkReader
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  use ExUnit.Case
  use GoogleAcceptanceTest, json: "test/operations/read-rows-acceptance.json"

  defp process_chunks(chunks) do
    {:ok, cr} = ChunkReader.open()
    initial = %{cr: cr, error: false, processed: []}
    Enum.reduce(chunks, initial, &process_chunk/2)
  end

  defp process_chunk(cc, accum) do
    chunk = build_chunk(cc)

    case ChunkReader.process(accum.cr, chunk) do
      {:ok, c, r} ->
        test_result = TestResult.from_chunk(c)
        %{cr: r, processed: [test_result | accum.processed]}

      {:error, _} ->
        %{cr: accum.cr, error: true, processed: nil}
    end
  end

  defp build_chunk(cc) do
    Map.put(cc, :row_status, chunk_status(cc))
    |> Map.drop([:commit_row, :reset_row])
    |> Map.to_list()
    |> CellChunk.new()
  end

  defp chunk_status(chunk) do
    cond do
      Map.get(chunk, :commit_row, false) ->
        {:commit_row, true}

      Map.get(chunk, :reset_row, false) ->
        {:reset_row, true}

      true ->
        nil
    end
  end

  defp results_error?(results), do: Enum.any?(results, &Map.get(&1, :error, false))
end

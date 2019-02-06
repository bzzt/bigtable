defmodule GoogleAcceptanceTest do
  defmacro __using__(json: json) do
    alias Bigtable.Reader.ChunkReader

    File.read!(json)
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:tests)
    |> Enum.map(fn t ->
      quote do
        test unquote(t.name) do
          %{chunks: chunks, results: results} = unquote(Macro.escape(t))

          has_error = initial = %{cr: %ChunkReader{}, error: false, processed: []}

          result = Enum.reduce(chunks, initial, &process_chunk/2)

          if results_error?(results) do
            assert result.error == true
          end
        end
      end
    end)
  end
end

defmodule ReadRowsAcceptanceTest do
  alias Bigtable.Reader.ChunkReader
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  use ExUnit.Case
  use GoogleAcceptanceTest, json: "test/operations/read-rows-acceptance.json"

  defp process_chunk(cc, accum) do
    chunk =
      Map.put(cc, :row_status, chunk_status(cc))
      |> Map.drop([:commit_row, :reset_row])
      |> Map.to_list()
      |> CellChunk.new()

    case ChunkReader.process(accum.cr, chunk) do
      {:ok, c, r} ->
        %{cr: r, processed: [c | accum.processed]}

      {:error, _} ->
        %{cr: accum.cr, error: true, processed: nil}
    end
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

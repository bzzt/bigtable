defmodule TestResult do
  alias Bigtable.ChunkReader.ReadItem
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  def from_chunk(family_name, %ReadItem{} = ri) do
    %{
      rk: ri.row_key,
      fm: family_name,
      qual: ri.qualifier,
      ts: ri.timestamp,
      value: ri.value,
      error: false,
      label: ri.label
    }
  end
end

defmodule GoogleAcceptanceTest do
  alias Bigtable.ChunkReader

  defmacro __using__(json: json) do
    File.read!(json)
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:tests)
    |> Enum.take(36)
    |> Enum.map(fn t ->
      quote do
        if unquote(t.name) == "simple reset" do
          IO.puts("WIP")
          @tag :wip
        end

        test(unquote(t.name)) do
          %{chunks: chunks, results: expected} = unquote(Macro.escape(t))

          result = process_chunks(chunks)
          {processed_status, processed_result} = result.processed

          if null_result?(chunks, expected) or results_error?(expected) do
            assert result.close_error == true or processed_status == :error
          else
            converted =
              processed_result
              |> Enum.flat_map(fn {family_name, read_items} ->
                read_items
                |> Enum.map(&TestResult.from_chunk(family_name, &1))
                |> Enum.reverse()
              end)

            assert converted == expected
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
  use GoogleAcceptanceTest, json: "test/google_acceptance/read-rows-acceptance.json"

  defp process_chunks(chunks) do
    {:ok, cr} = ChunkReader.open()

    processed =
      Enum.reduce(chunks, :ok, fn cc, accum ->
        case accum do
          {:error, _} ->
            accum

          _ ->
            chunk = build_chunk(cc)

            ChunkReader.process(cr, chunk)
        end
      end)

    %{close_error: ChunkReader.close(cr) != :ok, processed: processed}
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

  defp null_result?(chunks, results), do: length(chunks) > 0 and results == nil
  defp results_error?(results), do: Enum.any?(results, &Map.get(&1, :error, false))
end

defmodule TestResult do
  alias Bigtable.Data.ChunkReader.ReadCell
  alias Google.Bigtable.V2.ReadRowsResponse.CellChunk

  def from_chunk(row_key, %ReadCell{} = ri) do
    %{
      rk: row_key,
      fm: ri.family_name,
      qual: ri.qualifier,
      ts: ri.timestamp,
      value: ri.value,
      error: false,
      label: ri.label
    }
  end
end

defmodule GoogleAcceptanceTest do
  alias Bigtable.Data.ChunkReader

  defmacro __using__(json: json) do
    json
    |> File.read!()
    |> Poison.decode!(keys: :atoms)
    |> Map.get(:tests)
    |> Enum.take(60)
    |> Enum.map(fn t ->
      quote do
        test(unquote(t.name)) do
          %{chunks: chunks, results: expected} = unquote(Macro.escape(t))

          result = process_chunks(chunks)
          {processed_status, processed_result} = result.processed

          cond do
            expected == nil ->
              assert processed_result == %{}

            results_error?(expected) ->
              assert result.close_error == true or processed_status == :error

            true ->
              converted =
                processed_result
                |> Enum.flat_map(fn {row_key, read_items} ->
                  read_items
                  |> Enum.map(&TestResult.from_chunk(row_key, &1))
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
  alias Bigtable.Data.ChunkReader
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

    {close_status, _} = ChunkReader.close(cr)
    %{close_error: close_status != :ok, processed: processed}
  end

  defp build_chunk(cc) do
    cc
    |> Map.put(:row_status, chunk_status(cc))
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

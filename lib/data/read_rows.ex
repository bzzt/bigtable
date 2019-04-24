defmodule Bigtable.ReadRows do
  @moduledoc """
  Provides functionality for to building and submitting a `Google.Bigtable.V2.ReadRowsRequest`.
  """
  alias Bigtable.ChunkReader
  alias Bigtable.{Request, Utils}
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

  @type response :: {:ok, ChunkReader.chunk_reader_result()} | {:error, any()}

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` given an optional table name.

  Defaults to the configured table name if none is provided.

  ## Examples
      iex> table_name = "projects/project-id/instances/instance-id/tables/table-name"
      iex> Bigtable.ReadRows.build(table_name)
      %Google.Bigtable.V2.ReadRowsRequest{
        app_profile_id: "",
        filter: nil,
        rows: nil,
        rows_limit: 0,
        table_name: "projects/project-id/instances/instance-id/tables/table-name"
      }
  """
  @spec build(binary()) :: V2.ReadRowsRequest.t()
  def build(table_name \\ Utils.configured_table_name()) when is_binary(table_name) do
    V2.ReadRowsRequest.new(table_name: table_name, app_profile_id: "")
  end

  @doc """
  Submits a `Google.Bigtable.V2.ReadRowsRequest` to Bigtable.

  Can be called with either a `Google.Bigtable.V2.ReadRowsRequest` or an optional table name.
  """
  @spec read(V2.ReadRowsRequest.t() | binary()) :: response()
  def read(table_name \\ Utils.configured_table_name())

  def read(%V2.ReadRowsRequest{} = request) do
    request
    |> Request.process_request(&Stub.read_rows/3, stream: true)
    |> handle_response()
  end

  def read(table_name) when is_binary(table_name) do
    table_name
    |> build()
    |> read()
  end

  defp handle_response({:error, _} = response), do: response

  defp handle_response({:ok, response}) do
    response
    |> Enum.filter(&contains_chunks?/1)
    |> Enum.flat_map(fn {:ok, resp} -> resp.chunks end)
    |> process_chunks()
  end

  defp process_chunks(chunks) do
    {:ok, cr} = ChunkReader.open()

    chunks
    |> process_chunks(nil, cr)
  end

  defp process_chunks([], _result, chunk_reader) do
    ChunkReader.close(chunk_reader)
  end

  defp process_chunks(_chunks, {:error, _}, chunk_reader) do
    ChunkReader.close(chunk_reader)
  end

  defp process_chunks([h | t], _result, chunk_reader) do
    result =
      chunk_reader
      |> ChunkReader.process(h)

    process_chunks(t, result, chunk_reader)
  end

  defp contains_chunks?({:ok, response}), do: !Enum.empty?(response.chunks)
end

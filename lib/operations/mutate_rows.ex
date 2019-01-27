defmodule Bigtable.MutateRows do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.MutateRowsRequest` and submit them to Bigtable.
  """

  alias Bigtable.Connection
  alias Google.Bigtable.V2

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowsRequest` with a provided table name and a list of `Google.Bigtable.V2.MutateRowsRequest.Entry`.
  """
  @spec build(list(V2.MutateRowsRequest.Entry.t()), binary()) :: V2.MutateRowsRequest.t()
  def build(entries, table_name) when is_binary(table_name) and is_list(entries) do
    V2.MutateRowsRequest.new(
      table_name: table_name,
      entries: entries
    )
  end

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowsRequest` request with  a list of `Google.Bigtable.V2.MutateRowsRequest.Entry`.

  Uses the configured table name.
  """
  @spec build(list(V2.MutateRowsRequest.Entry.t())) :: V2.MutateRowsRequest.t()
  def build(entries) when is_list(entries) do
    build(entries, Bigtable.Utils.configured_table_name())
  end

  @doc """
  Submits a `Google.Bigtable.V2.MutateRowsRequest` to Bigtable.

  Can be called with either a list of `Google.Bigtable.V2.MutateRowsRequest.Entry` or a `Google.Bigtable.V2.MutateRowsRequest`.

  Returns a `Google.Bigtable.V2.MutateRowsResponse`
  """
  @spec mutate(Google.Bigtable.V2.MutateRowsRequest.t()) ::
          {:error, GRPC.RPCError.t()}
          | {:ok, V2.MutateRowsResponse.t()}
  def mutate(%V2.MutateRowsRequest{} = request) do
    connection = Connection.get_connection()

    metadata = Connection.get_metadata()

    {:ok, resp, _} =
      connection
      |> Bigtable.Stub.mutate_rows(request, metadata)

    result =
      resp
      |> Stream.take_while(&remaining_resp?/1)
      |> Enum.to_list()

    {:ok, result}
  end

  @spec mutate([Google.Bigtable.V2.MutateRowsRequest.Entry.t()]) ::
          {:error, GRPC.RPCError.t()}
          | {:ok, V2.MutateRowsResponse.t()}
  def mutate(entries) when is_list(entries) do
    request = build(entries)

    request
    |> mutate
  end

  defp remaining_resp?({status, resp}) do
    IO.puts("MutateRows status: #{inspect(status)}")
    status != :trailers
  end
end

defmodule Bigtable.Data.MutateRows do
  @moduledoc """
  Provides functionality for building and submitting a `Google.Bigtable.V2.MutateRowsRequest`.
  """
  alias Bigtable.{Request, Utils}
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

  @type response :: {:ok, V2.MutateRowsResponse.t()} | {:error, any()}

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowsRequest` given a `Google.Bigtable.V2.MutateRowsRequest.Entry` and optional table name.
  """
  @spec build(list(V2.MutateRowsRequest.Entry.t()), binary()) :: V2.MutateRowsRequest.t()
  def build(entries, table_name \\ Utils.configured_table_name())
      when is_binary(table_name) and is_list(entries) do
    V2.MutateRowsRequest.new(
      table_name: table_name,
      entries: entries
    )
  end

  @doc """
  Submits a `Google.Bigtable.V2.MutateRowsRequest` to Bigtable.

  Can be called with either a list of `Google.Bigtable.V2.MutateRowsRequest.Entry` or a `Google.Bigtable.V2.MutateRowsRequest`.

  Returns a `Google.Bigtable.V2.MutateRowsResponse`
  """
  @spec mutate(V2.MutateRowsRequest.t()) :: response()
  def mutate(%V2.MutateRowsRequest{} = request) do
    request
    |> Request.process_request(&Stub.mutate_rows/3, stream: true)
  end

  @spec mutate([V2.MutateRowsRequest.Entry.t()]) :: response()
  def mutate(entries) when is_list(entries) do
    entries
    |> build()
    |> mutate
  end
end

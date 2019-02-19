defmodule Bigtable.MutateRows do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.MutateRowsRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

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
  @spec mutate(V2.MutateRowsRequest.t()) :: {:ok, V2.MutateRowsResponse.t()} | {:error, binary()}
  def mutate(%V2.MutateRowsRequest{} = request) do
    request
    |> Utils.process_request(&Stub.mutate_rows/3, stream: true)
  end

  @spec mutate([V2.MutateRowsRequest.Entry.t()]) ::
          {:ok, V2.MutateRowsResponse.t()} | {:error, binary()}
  def mutate(entries) when is_list(entries) do
    request = build(entries)

    request
    |> mutate
  end
end

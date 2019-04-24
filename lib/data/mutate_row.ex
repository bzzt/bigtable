defmodule Bigtable.MutateRow do
  @moduledoc """
  Provides functionality for building and submitting a `Google.Bigtable.V2.MutateRowRequest`.
  """
  alias Bigtable.{Request, Utils}
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub
  alias V2.MutateRowsRequest.Entry

  @type response :: {:ok, V2.MutateRowResponse.t()} | {:error, any()}

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowRequest` given a `Google.Bigtable.V2.MutateRowsRequest.Entry` and optional table name.
  """
  @spec build(V2.MutateRowsRequest.Entry.t(), binary()) :: V2.MutateRowRequest.t()
  def build(%Entry{} = row_mutations, table_name \\ Utils.configured_table_name())
      when is_binary(table_name) do
    V2.MutateRowRequest.new(
      table_name: table_name,
      row_key: row_mutations.row_key,
      mutations: row_mutations.mutations
    )
  end

  @doc """
  Submits a `Google.Bigtable.V2.MutateRowRequest` given either a  `Google.Bigtable.V2.MutateRowsRequest.Entry` or a `Google.Bigtable.V2.MutateRowRequest`.

  Returns a `Google.Bigtable.V2.MutateRowResponse`.
  """
  @spec mutate(V2.MutateRowRequest.t()) :: response()
  def mutate(%V2.MutateRowRequest{} = request) do
    request
    |> Request.process_request(&Stub.mutate_row/3, single: true)
  end

  @spec mutate(V2.MutateRowsRequest.Entry.t()) :: response()
  def mutate(%Entry{} = entry) do
    entry
    |> build()
    |> mutate()
  end
end

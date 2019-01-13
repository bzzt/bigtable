defmodule Bigtable.MutateRow do
  alias Google.Bigtable.V2
  alias V2.MutateRowsRequest.Entry
  alias Bigtable.Connection

  @doc """
  Builds a MutateRow request with a provided table name and MutateRows.Entry
  """
  @spec build(V2.MutateRowsRequest.Entry.t(), binary()) :: V2.MutateRowRequest.t()
  def build(%Entry{} = row_mutations, table_name) when is_binary(table_name) do
    V2.MutateRowRequest.new(
      table_name: table_name,
      row_key: row_mutations.row_key,
      mutations: row_mutations.mutations
    )
  end

  @doc """
  Builds a MutateRow request with default table name and provided MutateRows.Entry
  """
  @spec build(V2.MutateRowsRequest.Entry.t()) :: V2.MutateRowRequest.t()
  def build(%Entry{} = row_mutations) do
    build(row_mutations, Bigtable.Utils.configured_table_name())
  end

  @doc """
  Submits a provided MutateRowRequest to Bigtable
  """
  def mutate(%V2.MutateRowRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_row(request)
  end

  @doc """
  Builds and submits a MutateRowRequest with a provided MutateRowsRequest.Entry
  """
  def mutate(%Entry{} = row_mutations) do
    build(row_mutations)
    |> mutate()
  end
end

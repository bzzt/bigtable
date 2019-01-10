defmodule Bigtable.MutateRow.Request do
  alias Bigtable.Mutation
  alias Google.Bigtable.V2

  @doc """
  Builds a MutateRow request with a provided table name
  """
  def build(table_name, %Mutation{} = row_mutations) when is_binary(table_name) do
    V2.MutateRowRequest.new(
      table_name: table_name,
      row_key: row_mutations.row_key,
      mutations: row_mutations.mutations
    )
  end

  @doc """
  Builds a MutateRow request with default table name if none provided
  """
  def build(%Mutation{} = row_mutations) do
    build(Bigtable.Request.table_name(), row_mutations)
  end
end

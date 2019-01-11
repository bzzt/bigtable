defmodule Bigtable.MutateRow do
  alias Google.Bigtable.V2
  alias V2.MutateRowsRequest.Entry
  alias Bigtable.Connection

  @doc """
  Builds a MutateRow request with a provided table name
  """
  def build(table_name, %Entry{} = row_mutations) when is_binary(table_name) do
    V2.MutateRowRequest.new(
      table_name: table_name,
      row_key: row_mutations.row_key,
      mutations: row_mutations.mutations
    )
  end

  @doc """
  Builds a MutateRow request with default table name if none provided
  """
  def build(%Entry{} = row_mutations) do
    build(Bigtable.Request.table_name(), row_mutations)
  end

  def mutate(%V2.MutateRowRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_row(request)
  end
end

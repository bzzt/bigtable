defmodule Bigtable.MutateRows do
  alias Google.Bigtable.V2
  alias Bigtable.Connection

  @doc """
  Builds a MutateRows request with a provided table name and a list of MutateRows.Entry
  """
  @spec build(list(V2.MutateRowsRequest.Entry.t()), binary()) :: V2.MutateRowsRequest.t()
  def build(entries, table_name) when is_binary(table_name) and is_list(entries) do
    V2.MutateRowsRequest.new(
      table_name: table_name,
      entries: entries
    )
  end

  @doc """
  Builds a MutateRows request with default table name and a list of MutateRows.Entry
  """
  @spec build(list(V2.MutateRowsRequest.Entry.t())) :: V2.MutateRowsRequest.t()
  def build(entries) when is_list(entries) do
    build(entries, Bigtable.Utils.configured_table_name())
  end

  def mutate(%V2.MutateRowsRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_rows(request)
  end

  def mutate(entries) when is_list(entries) do
    build(entries)
    |> mutate
  end
end
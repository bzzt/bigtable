defmodule Bigtable.MutateRow.Request do
  alias Google.Bigtable.V2

  @doc """
  Builds a MutateRow request with a provided table name
  """
  @spec build(binary()) :: %{:__struct__ => atom(), optional(atom()) => any()}
  def build(table_name) when is_binary(table_name) do
    V2.MutateRowRequest.new(table_name: table_name)
  end

  @doc """
  Builds a MutateRow request with default table name if none provided
  """
  @spec build() :: %{:__struct__ => atom(), optional(atom()) => any()}
  def build() do
    build(Bigtable.Request.table_name())
  end
end

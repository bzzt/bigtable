defmodule Bigtable.ReadRows.Request do
  alias Google.Bigtable.V2
  alias Bigtable.ReadRows.Filter

  @doc """
  Builds a ReadRows request with a provided table name
  """
  @spec build(binary()) :: Google.Bigtable.V2.ReadRowsRequest.t()
  def build(table_name) when is_binary(table_name) do
    V2.ReadRowsRequest.new(table_name: table_name)
    |> default_filters()
  end

  @doc """
  Builds a ReadRows request with default table name if none provided
  """
  def build() do
    build(Bigtable.Request.table_name())
  end

  @doc """
  Applies a RowFilter to a given ReadRowsRequest
  """
  @spec filter_rows(Google.Bigtable.V2.ReadRowsRequest.t(), Google.Bigtable.V2.RowFilter.t()) ::
          Google.Bigtable.V2.ReadRowsRequest.t()
  def filter_rows(%V2.ReadRowsRequest{} = request, %V2.RowFilter{} = filter) do
    %{request | filter: filter}
  end

  # Applies default filter of only the most recent cell per column
  defp default_filters(%V2.ReadRowsRequest{} = request) do
    column_filter = Filter.cells_per_column(1)
    default_chain = Filter.chain([column_filter])
    request |> filter_rows(default_chain)
  end
end

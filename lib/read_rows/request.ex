defmodule Bigtable.ReadRows.Request do
  alias Google.Bigtable.V2
  alias Bigtable.ReadRows.Filter

  def build() do
    build(nil)
  end

  def build(table_name) when is_binary(table_name) do
    V2.ReadRowsRequest.new(table_name: table_name)
    |> default_filters()
  end

  def build(_) do
    project = Application.get_env(:bigtable, :project)
    instance = Application.get_env(:bigtable, :instance)
    table = Application.get_env(:bigtable, :table)

    table_name = "projects/#{project}/instances/#{instance}/tables/#{table}"
    build(table_name)
  end

  def filter(%V2.ReadRowsRequest{} = request, %V2.RowFilter{} = filter) do
    %{request | filter: filter}
  end

  defp default_filters(%V2.ReadRowsRequest{} = request) do
    request |> filter(Filter.chain([Filter.cells_per_column(1)]))
  end
end

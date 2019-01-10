defmodule Bigtable.Request do
  @doc """
  Gets the default table name provided by the application's config file
  """
  def table_name() do
    project = Application.get_env(:bigtable, :project)
    instance = Application.get_env(:bigtable, :instance)
    table = Application.get_env(:bigtable, :table)

    "projects/#{project}/instances/#{instance}/tables/#{table}"
  end
end

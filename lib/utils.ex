defmodule Bigtable.Utils do
  @moduledoc false
  def configured_table_name do
    project = Application.get_env(:bigtable, :project)
    instance = Application.get_env(:bigtable, :instance)
    table = Application.get_env(:bigtable, :table)

    "projects/#{project}/instances/#{instance}/tables/#{table}"
  end
end

defmodule Bigtable.Utils do
  @moduledoc false

  def configured_table_name do
    instance = configured_instance_name()
    table = Application.get_env(:bigtable, :table)

    "#{instance}/tables/#{table}"
  end

  def configured_instance_name do
    project = get_project()
    instance = get_instance()
    "projects/#{project}/instances/#{instance}"
  end

  defp get_project do
    Application.get_env(:bigtable, :project)
  end

  defp get_instance do
    Application.get_env(:bigtable, :instance)
  end
end

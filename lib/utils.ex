defmodule Bigtable.Utils do
  @moduledoc false

  @spec configured_table_name() :: binary()
  def configured_table_name do
    instance = configured_instance_name()
    table = Application.get_env(:bigtable, :table)

    "#{instance}/tables/#{table}"
  end

  @spec configured_instance_name() :: binary()
  def configured_instance_name do
    project = get_project()
    instance = get_instance()
    "projects/#{project}/instances/#{instance}"
  end

  @spec get_project() :: binary()
  defp get_project do
    Application.get_env(:bigtable, :project)
  end

  @spec get_instance() :: binary()
  defp get_instance do
    Application.get_env(:bigtable, :instance)
  end
end

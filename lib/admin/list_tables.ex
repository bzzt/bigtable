defmodule Bigtable.Admin.ListTables do
  @moduledoc """
  Provides functions to build `Google.Bigtable.Admin.V2.ListTablesRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.Admin.V2
  alias V2.BigtableTableAdmin.Stub

  @doc """
  Builds a `Google.Bigtable.Admin.V2.ListTablesRequest` with a provided instance name.

  ## Examples
      iex> parent = "projects/[project_id]/instances/[instance_id]"
      iex> Bigtable.Admin.ListTables.build(parent)
      %Google.Bigtable.Admin.V2.ListTablesRequest{
        page_size: 0,
        page_token: "",
        parent: "projects/[project_id]/instances/[instance_id]",
        view: 0
      }
  """
  @spec build(binary()) :: V2.ListTablesRequest.t()
  def build(parent) when is_binary(parent) do
    V2.ListTablesRequest.new(parent: parent)
  end

  @doc """
  Builds a `Google.Bigtable.Admin.V2.ListTablesRequest` with the configured table name.
  ## Examples
      iex> Bigtable.Admin.ListTables.build()
      %Google.Bigtable.Admin.V2.ListTablesRequest{
        page_size: 0,
        page_token: "",
        parent: "projects/dev/instances/test",
        view: 0
      }
  """
  @spec build() :: V2.ListTablesRequest.t()

  def build do
    build(Bigtable.Utils.configured_instance_name())
  end

  @doc """
  Submits a `Google.Bigtable.Admin.V2.ListTablesRequest` to Bigtable.

  Can be called with either a `Google.Bigtable.Admin.V2.ListTablesRequest` or an instance name name to list tables from a non-configured instance.
  """
  def list(%V2.ListTablesRequest{} = request) do
    request
    |> Utils.process_request(&Stub.list_tables/3)
  end

  def list(instance_name) when is_binary(instance_name) do
    request = build(instance_name)

    request
    |> list()
  end

  @doc """
  Submits a `Google.Bigtable.Admin.V2.ListTablesRequest` to Bigtable.

  Without arguments, `Bigtable.ListTables.read` will list all tables from the configured instance.

  Returns a list of `{:ok, %Google.Bigtable.Admin.V2.ListTablesResponse{}}`.
  """
  def list do
    request = build()

    request
    |> list
  end
end

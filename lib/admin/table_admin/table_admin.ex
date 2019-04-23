defmodule Bigtable.Admin.TableAdmin do
  @moduledoc """
  Provides functions to build `Google.Bigtable.Admin.V2.ListTablesRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.Admin.V2
  alias V2.BigtableTableAdmin.Stub

  def list_tables(opts \\ []) do
    opts
    |> Keyword.put_new(:parent, Utils.configured_instance_name())
    |> V2.ListTablesRequest.new()
    |> Utils.process_request(&Stub.list_tables/3)
  end

  def create_table(table, table_id, opts \\ []) do
    V2.CreateTableRequest.new(
      parent: Keyword.get(opts, :parent, Utils.configured_instance_name()),
      table_id: table_id,
      table: table,
      initial_splits: Keyword.get(opts, :initial_splits, [])
    )
    |> Utils.process_request(&Stub.create_table/3)
  end

  def delete_table(name) do
    V2.DeleteTableRequest.new(name: name)
    |> Utils.process_request(&Stub.delete_table/3)
  end

  def get_table(name) do
    V2.GetTableRequest.new(name: name)
    |> Utils.process_request(&Stub.get_table/3)
  end
end

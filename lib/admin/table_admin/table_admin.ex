defmodule Bigtable.Admin.TableAdmin do
  @moduledoc """
  Provides functions to build `Google.Bigtable.Admin.V2.ListTablesRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.Admin.V2
  alias V2.BigtableTableAdmin.Stub

  def list_tables(opts \\ []) do
    Keyword.put_new(opts, :parent, Utils.configured_instance_name())
    |> V2.ListTablesRequest.new()
    |> Utils.process_request(&Stub.list_tables/3)
  end

  def create_table(table, opts) do
    opts = Keyword.put(opts, :parent, Utils.configured_instance_name())

    IO.inspect(Keyword.fetch!(opts, :parent))

    V2.CreateTableRequest.new(
      parent: Keyword.fetch!(opts, :parent),
      table_id: Keyword.fetch!(opts, :table_id),
      table: table,
      initial_splits: Keyword.get(opts, :initial_splits, [])
    )
    |> Utils.process_request(&Stub.create_table/3)
  end

  def delete_table(name) do
    V2.DeleteTableRequest.new(name: name)
    |> Utils.process_request(&Stub.delete_table/3)
  end
end

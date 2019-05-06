defmodule Bigtable.Admin.TableAdmin do
  @moduledoc """
  Provides functions to build `Google.Bigtable.Admin.V2.ListTablesRequest` and submit them to Bigtable.
  """
  alias Bigtable.{Request, Utils}
  alias Google.Bigtable.Admin.V2

  def list_tables(opts \\ []) do
    request =
      opts
      |> Keyword.put_new(:parent, Utils.configured_instance_name())
      |> V2.ListTablesRequest.new()

    query = %Bigtable.Query{request: request, type: :list_tables, api: :admin}

    query
    |> Request.submit_request()
  end

  def create_table(table, table_id, opts \\ []) do
    request =
      V2.CreateTableRequest.new(
        parent: Keyword.get(opts, :parent, Utils.configured_instance_name()),
        table_id: table_id,
        table: table,
        initial_splits: Keyword.get(opts, :initial_splits, [])
      )

    query = %Bigtable.Query{request: request, type: :create_table, api: :admin}

    query
    |> Request.submit_request()
  end

  def delete_table(name) do
    request = V2.DeleteTableRequest.new(name: name)

    query = %Bigtable.Query{request: request, type: :delete_table, api: :admin}

    query
    |> Request.submit_request()
  end

  def get_table(name) do
    request = V2.GetTableRequest.new(name: name)

    query = %Bigtable.Query{request: request, type: :get_table, api: :admin}

    query
    |> Request.submit_request()
  end
end

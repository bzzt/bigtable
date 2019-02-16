defmodule Bigtable.Admin.ListTables do
  @moduledoc """
  Provides functions to build `Google.Bigtable.Admin.V2.ListTablesRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.Admin.V2
  alias V2.BigtableTableAdmin.Stub

  def list(opts \\ []) do
    Keyword.put_new(opts, :parent, Utils.configured_instance_name())
    |> V2.ListTablesRequest.new()
    |> Utils.process_request(&Stub.list_tables/3)
  end
end

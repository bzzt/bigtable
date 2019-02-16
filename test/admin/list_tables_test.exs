defmodule ListTablesTest do
  alias Bigtable.Admin.ListTables
  alias Google.Bigtable.Admin.V2

  use ExUnit.Case

  doctest ListTables

  describe("Bigtable.Admin.ListTables/2") do
    test("should list existing tables") do
      {:ok, response} = ListTables.list()

      expected = %V2.ListTablesResponse{
        next_page_token: "",
        tables: [
          %V2.Table{
            cluster_states: %{},
            column_families: %{},
            granularity: 0,
            name: "projects/dev/instances/dev/tables/test"
          },
          %V2.Table{
            cluster_states: %{},
            column_families: %{},
            granularity: 0,
            name: "projects/dev/instances/dev/tables/dev"
          }
        ]
      }

      assert response == expected
    end
  end
end

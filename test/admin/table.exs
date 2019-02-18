defmodule TableAdminTest do
  alias Bigtable.Admin.TableAdmin
  alias Google.Bigtable.Admin.V2

  use ExUnit.Case

  doctest TableAdmin

  describe("Bigtable.Admin.TableAdmin.list_tables/2") do
    test("should list existing tables") do
      {:ok, response} = TableAdmin.list_tables()

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

defmodule TableAdminTest do
  alias Bigtable.Admin.{GcRule, Table, TableAdmin}
  alias Google.Bigtable.Admin.V2

  use ExUnit.Case

  doctest TableAdmin

  describe("Bigtable.Admin.TableAdmin.list_tables/2") do
    test("should list existing tables") do
      {:ok, response} = TableAdmin.list_tables()

      expected = [
        %V2.Table{
          cluster_states: %{},
          column_families: %{},
          granularity: 0,
          name: "projects/dev/instances/dev/tables/dev"
        },
        %V2.Table{
          cluster_states: %{},
          column_families: %{},
          granularity: 0,
          name: "projects/dev/instances/dev/tables/test"
        }
      ]

      sorted = Enum.sort(response.tables, fn t1, t2 -> t1.name < t2.name end)

      assert sorted == expected
    end
  end

  describe("Bigtagble.Admin.TableAdmin.create_table") do
    setup do
      table_name = "projects/dev/instances/dev/tables/created"

      on_exit(fn ->
        {:ok, _} = TableAdmin.delete_table(table_name)
      end)

      [table_name: table_name]
    end

    test "should create a table", context do
      {:ok, initial} = TableAdmin.list_tables()

      refute matching_table?(
               initial.tables,
               context.table_name
             )

      cf = %{
        "cf1" => GcRule.max_age(30_000)
      }

      cf
      |> Table.build()
      |> TableAdmin.create_table("created")

      {:ok, after_insert} = TableAdmin.list_tables()

      assert matching_table?(after_insert.tables, context.table_name)
    end
  end

  defp matching_table?(tables, table_name),
    do: Enum.any?(tables, &(Map.get(&1, :name) == table_name))
end

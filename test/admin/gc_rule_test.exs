defmodule GcRuleTest do
  alias Bigtable.Admin.{GcRule, Table, TableAdmin}
  alias Google.Bigtable.Admin.V2
  alias Google.Protobuf.Duration
  use ExUnit.Case

  setup do
    table_name = "projects/dev/instances/dev/tables/gc_rule"

    on_exit(fn ->
      {:ok, _} = TableAdmin.delete_table(table_name)
    end)

    [table_name: table_name]
  end

  describe("Bigtagble.Admin.GcRule.max_age/1") do
    test "should create a table with a max age gc rule", context do
      Table.build(%{
        "cf1" => GcRule.max_age(2_592_000_500)
      })
      |> TableAdmin.create_table("gc_rule")

      expected = %{
        "cf1" => %V2.ColumnFamily{
          gc_rule: %V2.GcRule{
            rule: {:max_age, %Duration{nanos: 500_000_000, seconds: 2_592_000}}
          }
        }
      }

      {:ok, response} = TableAdmin.get_table(context.table_name)

      assert response.column_families == expected
    end
  end

  describe("Bigtable.Admin.GcRule.max_num_versions/1") do
    test "should create a table with a max version gc rule", context do
      Table.build(%{
        "cf1" => GcRule.max_num_versions(1)
      })
      |> TableAdmin.create_table("gc_rule")

      expected = %{
        "cf1" => %V2.ColumnFamily{
          gc_rule: %V2.GcRule{
            rule: {:max_num_versions, 1}
          }
        }
      }

      {:ok, response} = TableAdmin.get_table(context.table_name)
      assert response.column_families == expected
    end
  end

  describe("Bigtable.Admin.GcRule.union/1") do
    test "should create a table with a union gc rule", context do
      rules = [
        GcRule.max_num_versions(1),
        GcRule.max_age(3000)
      ]

      Table.build(%{
        "cf1" => GcRule.union(rules)
      })
      |> TableAdmin.create_table("gc_rule")

      expected = %{
        "cf1" => %V2.ColumnFamily{
          gc_rule: %V2.GcRule{
            rule:
              {:union,
               %V2.GcRule.Union{
                 rules: rules
               }}
          }
        }
      }

      {:ok, response} = TableAdmin.get_table(context.table_name)
      assert response.column_families == expected
    end
  end

  describe("Bigtable.Admin.GcRule.intersection/1") do
    test "should create a table with an intersection gc rule", context do
      rules = [
        GcRule.max_num_versions(1),
        GcRule.max_age(3000)
      ]

      Table.build(%{
        "cf1" => GcRule.intersection(rules)
      })
      |> TableAdmin.create_table("gc_rule")

      expected = %{
        "cf1" => %V2.ColumnFamily{
          gc_rule: %V2.GcRule{
            rule:
              {:intersection,
               %V2.GcRule.Intersection{
                 rules: rules
               }}
          }
        }
      }

      {:ok, response} = TableAdmin.get_table(context.table_name)
      assert response.column_families == expected
    end
  end
end

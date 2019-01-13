defmodule MutateRowTest do
  alias Google.Bigtable.V2.MutateRowsRequest.Entry
  alias Bigtable.{Mutations, MutateRow}

  use ExUnit.Case

  doctest Bigtable

  setup do
    [
      entry: Mutations.build("Test#123")
    ]
  end

  describe "MutateRow.build() " do
    test "should build a MutateRowRequest with configured table", context do
      expected = %Google.Bigtable.V2.MutateRowRequest{
        app_profile_id: "",
        mutations: [],
        row_key: "Test#123",
        table_name: Bigtable.Utils.configured_table_name()
      }

      result = context.entry |> MutateRow.build()

      assert result == expected
    end

    test "should build a MutateRowRequest with custom table", context do
      table_name = "custom-table"

      expected = %Google.Bigtable.V2.MutateRowRequest{
        app_profile_id: "",
        mutations: [],
        row_key: "Test#123",
        table_name: table_name
      }

      result =
        context.entry
        |> MutateRow.build(table_name)

      assert result == expected
    end
  end
end

defmodule MutateRowsTest do
  @moduledoc false
  # TODO: Integration tests including errors

  alias Bigtable.Data.{MutateRows, Mutations}
  use ExUnit.Case

  setup do
    [
      entries: [Mutations.build("Test#123"), Mutations.build("Test#124")]
    ]
  end

  describe "MutateRow.build() " do
    test "should build a MutateRowsRequest with configured table", context do
      expected = %Google.Bigtable.V2.MutateRowsRequest{
        app_profile_id: "",
        entries: [
          %Google.Bigtable.V2.MutateRowsRequest.Entry{
            mutations: [],
            row_key: "Test#123"
          },
          %Google.Bigtable.V2.MutateRowsRequest.Entry{
            mutations: [],
            row_key: "Test#124"
          }
        ],
        table_name: Bigtable.Utils.configured_table_name()
      }

      result = context.entries |> MutateRows.build()

      assert result == expected
    end

    test "should build a MutateRowsRequest with custom table", context do
      table_name = "custom-table"

      expected = %Google.Bigtable.V2.MutateRowsRequest{
        app_profile_id: "",
        entries: [
          %Google.Bigtable.V2.MutateRowsRequest.Entry{
            mutations: [],
            row_key: "Test#123"
          },
          %Google.Bigtable.V2.MutateRowsRequest.Entry{
            mutations: [],
            row_key: "Test#124"
          }
        ],
        table_name: table_name
      }

      result =
        context.entries
        |> MutateRows.build(table_name)

      assert result == expected
    end
  end
end

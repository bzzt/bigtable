defmodule MutateRowTest do
  @moduledoc false
  # TODO: Integration tests including errors

  alias Bigtable.{MutateRow, Mutations}

  use ExUnit.Case

  setup do
    [
      entry: Mutations.build("Test#123")
    ]
  end

  describe "MutateRow.build() " do
    test "should build a MutateRowRequest with configured table", context do
      result = context.entry |> MutateRow.build()

      assert result == expected_request()
    end

    test "should build a MutateRowRequest with custom table", context do
      table_name = "custom-table"

      result =
        context.entry
        |> MutateRow.build(table_name)

      assert result == expected_request(table_name)
    end
  end

  defp expected_request(table_name \\ Bigtable.Utils.configured_table_name()) do
    %Google.Bigtable.V2.MutateRowRequest{
      app_profile_id: "",
      mutations: [],
      row_key: "Test#123",
      table_name: table_name
    }
  end
end

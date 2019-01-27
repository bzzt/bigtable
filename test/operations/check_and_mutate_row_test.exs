# defmodule CheckAndMutateRowTest do
#   @moduledoc false
#   alias Bigtable.{Mutations, MutateRow, CheckAndMutateRow}

#   use ExUnit.Case

#   doctest CheckAndMutateRow

#   setup do
#     assert ReadRows.read() = []

#     row_key = "Test#123"
#     column_family = "cf1"
#     column_qualifier = "column"

#     true_entry =
#       Mutations.build(row_key) |> Mutations.set_cell(column_family, column_qualifier, "true")

#     false_entry =
#       Mutations.build(row_key) |> Mutations.set_cell(column_family, column_qualifier, "false")

#     initial_value =
#       Mutations.build(row_key) |> Mutations.set_cell(column_family, column_qualifier, 10)

#     initial_value
#     |> MutateRow.mutate()

#     on_exit(fn ->
#       mutation = Mutations.build(row_key) |> Mutations.delete_from_row()

#       mutation |> MutateRow.mutate()
#     end)

#     [
#       initial_entry: Mutations.build("Test#123"),
#       true_entry: true_entry,
#       false_entry: false_entry
#     ]
#   end

#   describe "CheckAndMutateRow.build()" do
#     test "should build a CheckAndMutateRowRequest with configured table", context do
#     end

#     test "should build a CheckAndMutateRowRequest with custom table", context
#   end

#   defp expected_request(table_name \\ Bigtable.Utils.configured_table_name()) do
#     %Google.Bigtable.V2.MutateRowRequest{
#       app_profile_id: "",
#       true_mutations: [],
#       row_key: "Test#123",
#       table_name: table_name
#     }
#   end
# end

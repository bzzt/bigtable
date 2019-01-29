defmodule CheckAndMutateRowTest do
  @moduledoc false
  alias Bigtable.{Mutations, MutateRow, CheckAndMutate}

  use ExUnit.Case

  doctest CheckAndMutate

  # setup do
  #   assert ReadRows.read() = []

  #   row_key = "Test#123"
  #   column_family = "cf1"
  #   column_qualifier = "column"

  #   true_entry =
  #     Mutations.build(row_key) |> Mutations.set_cell(column_family, column_qualifier, "true")

  #   false_entry =
  #     Mutations.build(row_key) |> Mutations.set_cell(column_family, column_qualifier, "false")

  #   initial_value =
  #     Mutations.build(row_key) |> Mutations.set_cell(column_family, column_qualifier, 10)

  #   initial_value
  #   |> MutateRow.mutate()

  #   on_exit(fn ->
  #     mutation = Mutations.build(row_key) |> Mutations.delete_from_row()

  #     mutation |> MutateRow.mutate()
  #   end)

  #   [
  #     initial_entry: Mutations.build("Test#123"),
  #     true_entry: true_entry,
  #     false_entry: false_entry
  #   ]
  # end

  describe "CheckAndMutateRow.build()" do
    test "should build a CheckAndMutateRowRequest with configured table", context do
      expected = expected_request()

      assert CheckAndMutate.build("Test#123") == expected
    end

    test "should build a CheckAndMutateRowRequest with custom table", context do
      table = "custom_table"

      expected = expected_request(table)

      assert CheckAndMutate.build(table, "Test#123") == expected
    end
  end

  defp expected_request(table_name \\ Bigtable.Utils.configured_table_name()) do
    %Google.Bigtable.V2.CheckAndMutateRowRequest{
      app_profile_id: "",
      predicate_filter: nil,
      true_mutations: [],
      false_mutations: [],
      row_key: "Test#123",
      table_name: table_name
    }
  end
end

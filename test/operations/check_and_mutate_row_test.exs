defmodule CheckAndMutateRowTest do
  @moduledoc false
  alias Bigtable.{CheckAndMutateRow, Mutations, MutateRow, ReadRows, RowFilter}

  use ExUnit.Case

  doctest CheckAndMutateRow

  setup do
    assert ReadRows.read() == {:ok, []}

    row_key = "Test#123"
    qualifier = "column"

    {:ok, _} =
      Mutations.build(row_key)
      |> Mutations.set_cell("cf1", qualifier, "value", 0)
      |> MutateRow.build()
      |> MutateRow.mutate()

    on_exit(fn ->
      mutation = Mutations.build(row_key) |> Mutations.delete_from_row()

      mutation |> MutateRow.mutate()
    end)

    [
      qualifier: qualifier,
      row_key: row_key
    ]
  end

  describe "CheckAndMutateRow.mutate/2" do
    test "should apply a single truthy mutation", context do
      filter = RowFilter.column_qualifier_regex(context.qualifier)

      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      CheckAndMutateRow.build(context.row_key)
      |> CheckAndMutateRow.predicate(filter)
      |> CheckAndMutateRow.if_true(mutation)
      |> IO.inspect()
      |> CheckAndMutateRow.mutate()
    end
  end
end

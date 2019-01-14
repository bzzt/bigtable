defmodule MutationsTest do
  alias Google.Bigtable.V2.MutateRowsRequest.Entry
  alias Bigtable.Mutations

  use ExUnit.Case

  doctest Mutations

  setup do
    [
      entry: Mutations.build("Test#123"),
      row_key: "Test#123",
      family_name: "testFamily",
      column_qualifier: "testColumn",
      value: "test"
    ]
  end

  describe "Mutations.build " do
    test "should build a MutateRowsRequest Entry struct", context do
      expected = %Entry{
        mutations: [],
        row_key: context.row_key
      }

      assert context.entry == expected
    end
  end

  describe "Mutations.set_cell" do
    test "should return a SetCell struct", context do
      family_name = context.family_name
      column_qualifier = context.column_qualifier
      value = context.value

      expected = %Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation:
              {:set_cell,
               %Google.Bigtable.V2.Mutation.SetCell{
                 column_qualifier: column_qualifier,
                 family_name: family_name,
                 timestamp_micros: -1,
                 value: value
               }}
          }
        ],
        row_key: context.row_key
      }

      result = context.entry |> Mutations.set_cell(family_name, column_qualifier, value)

      assert result == expected
    end
  end

  describe "Mutations.delete_from_column" do
    test "should return a DeleteFromColumn struct", context do
      family_name = context.family_name
      column_qualifier = context.column_qualifier

      expected = %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation:
              {:delete_from_column,
               %Google.Bigtable.V2.Mutation.DeleteFromColumn{
                 family_name: family_name,
                 column_qualifier: column_qualifier,
                 time_range: %Google.Bigtable.V2.TimestampRange{
                   end_timestamp_micros: 0,
                   start_timestamp_micros: 0
                 }
               }}
          }
        ],
        row_key: context.row_key
      }

      result = context.entry |> Mutations.delete_from_column(family_name, column_qualifier)

      assert result == expected
    end
  end

  describe "Mutations.delete_from_family" do
    test "should return a DeleteFromFamily struct", context do
      family_name = context.family_name

      expected = %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation:
              {:delete_from_family,
               %Google.Bigtable.V2.Mutation.DeleteFromFamily{family_name: "testFamily"}}
          }
        ],
        row_key: "Test#123"
      }

      result = context.entry |> Mutations.delete_from_family(family_name)

      assert result == expected
    end
  end

  describe "Mutations.delete_from_row" do
    test "should return a DeleteFromRow struct", context do
      expected = %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation: {:delete_from_row, %Google.Bigtable.V2.Mutation.DeleteFromRow{}}
          }
        ],
        row_key: "Test#123"
      }

      result = context.entry |> Mutations.delete_from_row()

      assert result == expected
    end
  end
end

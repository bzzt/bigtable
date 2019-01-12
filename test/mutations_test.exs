defmodule MutationsTest do
  alias Google.Bigtable.V2.MutateRowsRequest.Entry
  alias Bigtable.{MutateRow, Mutations}
  use ExUnit.Case

  doctest Bigtable

  @row_key "Test#123"

  setup do
    [entry: Mutations.build(@row_key)]
  end

  describe "Mutations.build " do
    test "should build a MutateRowsRequest Entry struct", context do
      expected = %Entry{
        mutations: [],
        row_key: @row_key
      }

      assert context.entry == expected
    end
  end

  describe "Mutations.SetCell" do
    test "should return a SetCell struct", context do
      family_name = "testFamily"
      column_qualifier = "testColumn"
      value = "test"

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
        row_key: @row_key
      }

      result = context.entry |> Mutations.set_cell(family_name, column_qualifier, value)

      assert result == expected
    end
  end
end

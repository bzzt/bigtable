defmodule TypedMutationsTest do
  alias Bigtable.Typed.Mutations

  use ExUnit.Case

  describe "Typed.Mutations.create_mutations" do
    setup do
      [
        row_key: "Test#1",
        type_spec: %{
          test_family: %{
            test_column: :boolean,
            test_nested: %{
              nested_a: :boolean,
              nested_b: :integer,
              double_nested: %{
                double_nested_a: :boolean,
                double_nested_b: :integer
              }
            }
          }
        }
      ]
    end

    test "should create mutations for a nested map", context do
      map = %{
        test_family: %{
          test_column: false,
          test_nested: %{
            nested_a: true,
            nested_b: 2,
            double_nested: %{
              double_nested_a: true,
              double_nested_b: 2
            }
          }
        }
      }

      expected = expected_entry(<<0, 0, 0, 1>>, <<0, 0, 0, 2>>)

      result = Mutations.create_mutations(context.row_key, context.type_spec, map)

      assert result == expected
    end

    test "should create nil properties for nil map value", context do
      map = %{
        test_family: %{
          test_column: false,
          test_nested: nil
        }
      }

      expected = expected_entry("", "")

      result = Mutations.create_mutations(context.row_key, context.type_spec, map)

      assert result == expected
    end
  end

  defp expected_entry(a_value, b_value) do
    %Google.Bigtable.V2.MutateRowsRequest.Entry{
      mutations: [
        %Google.Bigtable.V2.Mutation{
          mutation:
            {:set_cell,
             %Google.Bigtable.V2.Mutation.SetCell{
               column_qualifier: "test_column",
               family_name: "test_family",
               timestamp_micros: -1,
               value: <<0, 0, 0, 0>>
             }}
        },
        %Google.Bigtable.V2.Mutation{
          mutation:
            {:set_cell,
             %Google.Bigtable.V2.Mutation.SetCell{
               column_qualifier: "test_nested.double_nested.double_nested_a",
               family_name: "test_family",
               timestamp_micros: -1,
               value: a_value
             }}
        },
        %Google.Bigtable.V2.Mutation{
          mutation:
            {:set_cell,
             %Google.Bigtable.V2.Mutation.SetCell{
               column_qualifier: "test_nested.double_nested.double_nested_b",
               family_name: "test_family",
               timestamp_micros: -1,
               value: b_value
             }}
        },
        %Google.Bigtable.V2.Mutation{
          mutation:
            {:set_cell,
             %Google.Bigtable.V2.Mutation.SetCell{
               column_qualifier: "test_nested.nested_a",
               family_name: "test_family",
               timestamp_micros: -1,
               value: a_value
             }}
        },
        %Google.Bigtable.V2.Mutation{
          mutation:
            {:set_cell,
             %Google.Bigtable.V2.Mutation.SetCell{
               column_qualifier: "test_nested.nested_b",
               family_name: "test_family",
               timestamp_micros: -1,
               value: b_value
             }}
        }
      ],
      row_key: "Test#1"
    }
  end
end

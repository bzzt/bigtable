defmodule RowFilterTest do
  @moduledoc false
  alias Bigtable.RowFilter

  use ExUnit.Case

  doctest RowFilter

  setup do
    [
      request: %Google.Bigtable.V2.ReadRowsRequest{
        app_profile_id: "",
        filter: %Google.Bigtable.V2.RowFilter{
          filter:
            {:chain,
             %Google.Bigtable.V2.RowFilter.Chain{
               filters: []
             }}
        },
        rows: nil,
        rows_limit: 0,
        table_name: Bigtable.Utils.configured_table_name()
      }
    ]
  end

  describe "RowFilter.chain" do
    test "should apply a V2.RowFilter.Chain to a V2.ReadRowsRequest given a list of V2.RowFilter",
         context do
      filters = [
        %Google.Bigtable.V2.RowFilter{
          filter: {:cells_per_column_limit_filter, 1}
        },
        %Google.Bigtable.V2.RowFilter{
          filter: {:cells_per_column_limit_filter, 2}
        }
      ]

      expected = expected_chain(filters) |> expected_request()

      assert RowFilter.chain(context.request, filters) == expected
    end
  end

  describe "RowFilter.cells_per_column" do
    setup do
      limit = 1

      [
        limit: limit,
        filter: %Google.Bigtable.V2.RowFilter{
          filter: {:cells_per_column_limit_filter, 1}
        }
      ]
    end

    test "should apply a cells_per_column_limit V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.filter)

      assert RowFilter.cells_per_column(context.request, context.limit) == expected
    end

    test "should return a cells_per_column_limit V2.RowFilter given an integer", context do
      assert RowFilter.cells_per_column(context.limit) == context.filter
    end
  end

  describe "RowFilter.row_key_regex" do
    setup do
      regex = "^Test#\w+"

      [
        regex: regex,
        filter: %Google.Bigtable.V2.RowFilter{
          filter: {:row_key_regex_filter, regex}
        }
      ]
    end

    test "should apply a row_key_regex V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.filter)

      assert RowFilter.row_key_regex(context.request, context.regex) == expected
    end

    test "should return a row_key_regex V2.RowFilter given a column limit", context do
      assert RowFilter.row_key_regex(context.regex) == context.filter
    end
  end

  describe "RowFilter.value_regex" do
    setup do
      regex = "^test$"

      [
        regex: regex,
        filter: %Google.Bigtable.V2.RowFilter{
          filter: {:value_regex_filter, regex}
        }
      ]
    end

    test "should apply a value_regex V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.filter)

      assert RowFilter.value_regex(context.request, context.regex) == expected
    end

    test "should return a value_regex V2.RowFilter given a regex", context do
      assert RowFilter.value_regex(context.regex) == context.filter
    end
  end

  describe "RowFilter.family_name_regex" do
    setup do
      regex = "^familyTest$"

      [
        regex: regex,
        filter: %Google.Bigtable.V2.RowFilter{
          filter: {:family_name_regex_filter, regex}
        }
      ]
    end

    test "should apply a family_name_regex V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.filter)

      assert RowFilter.family_name_regex(context.request, context.regex) == expected
    end

    test "should return a family_name_regex V2.RowFilter given a regex", context do
      assert RowFilter.family_name_regex(context.regex) == context.filter
    end
  end

  defp expected_chain(filters) when is_list(filters) do
    %Google.Bigtable.V2.RowFilter{
      filter:
        {:chain,
         %Google.Bigtable.V2.RowFilter.Chain{
           filters: filters
         }}
    }
  end

  defp expected_request(filter) do
    %Google.Bigtable.V2.ReadRowsRequest{
      app_profile_id: "",
      filter: filter,
      rows: nil,
      rows_limit: 0,
      table_name: Bigtable.Utils.configured_table_name()
    }
  end
end

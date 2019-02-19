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

  describe "RowFilter.column_qualifier_regex" do
    setup do
      regex = "^columnTest$"

      [
        regex: regex,
        filter: %Google.Bigtable.V2.RowFilter{
          filter: {:column_qualifier_regex_filter, regex}
        }
      ]
    end

    test "should apply a column_qualifier_regex V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.filter)

      assert RowFilter.column_qualifier_regex(context.request, context.regex) == expected
    end

    test "should return a column_qualifier_regex V2.RowFilter given a regex", context do
      assert RowFilter.column_qualifier_regex(context.regex) == context.filter
    end
  end

  describe "RowFilter.column_range" do
    setup do
      family_name = "cf1"
      start_qualifier = "column2"
      end_qualifier = "column4"

      [
        family_name: family_name,
        inclusive_range: {start_qualifier, end_qualifier},
        inclusive_range_flagged: {start_qualifier, end_qualifier, true},
        exclusive_range: {start_qualifier, end_qualifier, false},
        inclusive_filter: %Google.Bigtable.V2.RowFilter{
          filter:
            {:column_range_filter,
             %Google.Bigtable.V2.ColumnRange{
               family_name: family_name,
               start_qualifier: {:start_qualifier_closed, start_qualifier},
               end_qualifier: {:end_qualifier_closed, end_qualifier}
             }}
        },
        exclusive_filter: %Google.Bigtable.V2.RowFilter{
          filter:
            {:column_range_filter,
             %Google.Bigtable.V2.ColumnRange{
               family_name: family_name,
               start_qualifier: {:start_qualifier_open, start_qualifier},
               end_qualifier: {:end_qualifier_open, end_qualifier}
             }}
        }
      ]
    end

    test "should apply an inclusive column_range V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.inclusive_filter)

      family_name = context.family_name
      request = context.request

      with_flag = RowFilter.column_range(request, family_name, context.inclusive_range_flagged)

      without_flag = RowFilter.column_range(request, family_name, context.inclusive_range)

      assert with_flag == expected
      assert without_flag == expected
    end

    test "should apply an exclusive column_range V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.exclusive_filter)

      result =
        RowFilter.column_range(context.request, context.family_name, context.exclusive_range)

      assert result == expected
    end

    test "should return an inclusive column_range V2.RowFilter given a range",
         context do
      expected = context.inclusive_filter

      family_name = context.family_name

      with_flag = RowFilter.column_range(family_name, context.inclusive_range_flagged)
      without_flag = RowFilter.column_range(family_name, context.inclusive_range)

      assert with_flag == expected
      assert without_flag == expected
    end

    test "should return an exclusive column_range V2.RowFilter given a range", context do
      expected = context.exclusive_filter

      result = RowFilter.column_range(context.family_name, context.exclusive_range)

      assert result == expected
    end
  end

  describe "RowFilter.timestamp_range" do
    test "should apply a timerange filter V2.RowFilter to a V2.ReadRowsRequest", context do
      start_timestamp = 1000
      end_timestamp = 2000
      range = [start_timestamp: start_timestamp, end_timestamp: end_timestamp]

      filter = expected_timestamp_filter(start_timestamp, end_timestamp)

      expected = expected_request(filter)

      result = RowFilter.timestamp_range(context.request, range)

      assert result == expected
    end

    test "should return default timestamp range when no timestamps provided" do
      expected = expected_timestamp_filter(0, 0)

      assert RowFilter.timestamp_range([]) == expected
    end

    test "should return timestamp range with start and end provided" do
      start_timestamp = 1000
      end_timestamp = 2000

      expected = expected_timestamp_filter(start_timestamp, end_timestamp)

      range = [start_timestamp: start_timestamp, end_timestamp: end_timestamp]

      result = RowFilter.timestamp_range(range)

      assert result == expected
    end
  end

  defp expected_timestamp_filter(start_timestamp, end_timestamp) do
    %Google.Bigtable.V2.RowFilter{
      filter:
        {:timestamp_range_filter,
         %Google.Bigtable.V2.TimestampRange{
           start_timestamp_micros: start_timestamp,
           end_timestamp_micros: end_timestamp
         }}
    }
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

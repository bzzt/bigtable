defmodule RowFilterIntegration do
  @moduledoc false
  alias Bigtable.{ChunkReader, MutateRow, MutateRows, Mutations, ReadRows, RowFilter}
  alias ChunkReader.ReadCell
  alias Google.Protobuf.{BytesValue, StringValue}

  use ExUnit.Case

  setup do
    assert ReadRows.read() == {:ok, %{}}

    row_keys = ["Test#1", "Test#2", "Other#1"]

    on_exit(fn ->
      mutations =
        Enum.map(row_keys, fn key ->
          entry = Mutations.build(key)

          entry
          |> Mutations.delete_from_row()
        end)

      mutations
      |> MutateRows.mutate()
    end)

    [
      row_keys: row_keys
    ]
  end

  describe "RowFilter.cells_per_column" do
    test "should properly limit the number of cells returned" do
      seed_multiple_values(3)

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 3000,
            value: "3"
          }
        ]
      }

      {:ok, filtered} =
        ReadRows.build()
        |> RowFilter.cells_per_column(1)
        |> ReadRows.read()

      assert filtered == expected
    end
  end

  describe "RowFilter.row_key_regex" do
    test "should properly filter rows based on row key", context do
      seed_values(context)

      expected_test = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value"
          }
        ]
      }

      expected_other = %{
        "Other#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Other#1",
            timestamp: 0,
            value: "value"
          }
        ]
      }

      request = ReadRows.build()

      {:ok, test_filtered} =
        request
        |> RowFilter.row_key_regex("^Test#\\w+")
        |> ReadRows.read()

      {:ok, other_filtered} =
        request
        |> RowFilter.row_key_regex("^Other#\\w+")
        |> ReadRows.read()

      assert test_filtered == expected_test
      assert other_filtered == expected_other
    end
  end

  describe "RowFilter.value_regex" do
    test "should properly filter a single row based on value" do
      mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column1", "foo", 0)
        |> Mutations.set_cell("cf1", "column2", "bar", 0)
        |> Mutations.set_cell("cf2", "column1", "bar", 0)
        |> Mutations.set_cell("cf2", "column2", "foo", 0)

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: "Test#1",
            timestamp: 0,
            value: "foo"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 0,
            value: "foo"
          }
        ]
      }

      {:ok, _} =
        mutation
        |> MutateRow.build()
        |> MutateRow.mutate()

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.value_regex("foo")
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter multiple rows based on value" do
      first_mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column1", "foo", 0)
        |> Mutations.set_cell("cf1", "column2", "bar", 0)
        |> Mutations.set_cell("cf2", "column1", "bar", 0)
        |> Mutations.set_cell("cf2", "column2", "foo", 0)

      second_mutation =
        Mutations.build("Test#2")
        |> Mutations.set_cell("cf1", "column1", "foo", 0)
        |> Mutations.set_cell("cf1", "column2", "bar", 0)
        |> Mutations.set_cell("cf2", "column1", "bar", 0)
        |> Mutations.set_cell("cf2", "column2", "foo", 0)

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: "Test#1",
            timestamp: 0,
            value: "foo"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 0,
            value: "foo"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: "Test#2",
            timestamp: 0,
            value: "foo"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#2",
            timestamp: 0,
            value: "foo"
          }
        ]
      }

      {:ok, _} =
        [first_mutation, second_mutation]
        |> MutateRows.build()
        |> MutateRows.mutate()

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.value_regex("foo")
        |> ReadRows.read()

      assert result == expected
    end
  end

  describe "RowFilter.family_name_regex" do
    test "should properly filter a single row based on family name" do
      mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column", "value", 0)
        |> Mutations.set_cell("cf2", "column", "value", 0)
        |> Mutations.set_cell("otherFamily", "column", "value", 0)

      cf_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          }
        ]
      }

      other_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "otherFamily"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          }
        ]
      }

      {:ok, _} =
        mutation
        |> MutateRow.build()
        |> MutateRow.mutate()

      {:ok, cf_result} =
        ReadRows.build()
        |> RowFilter.family_name_regex("^cf\\w")
        |> ReadRows.read()

      {:ok, other_result} =
        ReadRows.build()
        |> RowFilter.family_name_regex("^other?\\w{0,}")
        |> ReadRows.read()

      assert cf_result == cf_expected
      assert other_result == other_expected
    end

    test "should properly filter a multiple rows based on family name" do
      first_mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column", "value", 0)
        |> Mutations.set_cell("cf2", "column", "value", 0)
        |> Mutations.set_cell("otherFamily", "column", "value", 0)

      second_mutation =
        Mutations.build("Test#2")
        |> Mutations.set_cell("cf1", "column", "value", 0)
        |> Mutations.set_cell("otherFamily", "column", "value", 0)

      cf_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value"
          }
        ]
      }

      other_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "otherFamily"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "otherFamily"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value"
          }
        ]
      }

      {:ok, _} =
        [first_mutation, second_mutation]
        |> MutateRows.build()
        |> MutateRows.mutate()

      {:ok, cf_result} =
        ReadRows.build()
        |> RowFilter.family_name_regex("cf\\w{0,}")
        |> ReadRows.read()

      {:ok, other_result} =
        ReadRows.build()
        |> RowFilter.family_name_regex("other\\w{0,}")
        |> ReadRows.read()

      assert cf_result == cf_expected
      assert other_result == other_expected
    end
  end

  describe "RowFilter.column_qualifier_regex" do
    test "should properly filter a single row based on column qualifier" do
      mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "foo-cf1", "bar-value", 0)
        |> Mutations.set_cell("cf1", "bar-cf1", "baz-value", 0)
        |> Mutations.set_cell("cf2", "foo-cf2", "baz-value", 0)
        |> Mutations.set_cell("cf2", "bar-cf2", "foo-value", 0)
        |> Mutations.set_cell("otherFamily", "bar-other", "other-value", 0)

      foo_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "foo-cf2"},
            row_key: "Test#1",
            timestamp: 0,
            value: "baz-value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "foo-cf1"},
            row_key: "Test#1",
            timestamp: 0,
            value: "bar-value"
          }
        ]
      }

      bar_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "otherFamily"},
            label: "",
            qualifier: %BytesValue{value: "bar-other"},
            row_key: "Test#1",
            timestamp: 0,
            value: "other-value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "bar-cf2"},
            row_key: "Test#1",
            timestamp: 0,
            value: "foo-value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "bar-cf1"},
            row_key: "Test#1",
            timestamp: 0,
            value: "baz-value"
          }
        ]
      }

      {:ok, _} =
        mutation
        |> MutateRow.build()
        |> MutateRow.mutate()

      {:ok, foo_result} =
        ReadRows.build()
        |> RowFilter.column_qualifier_regex("foo-?\\w{0,}")
        |> ReadRows.read()

      {:ok, bar_result} =
        ReadRows.build()
        |> RowFilter.column_qualifier_regex("bar-?\\w{0,}")
        |> ReadRows.read()

      assert foo_result == foo_expected
      assert bar_result == bar_expected
    end

    test "should properly filter a multiple rows based on column qualifier" do
      first_mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "bar-column", "foo-value", 0)
        |> Mutations.set_cell("cf2", "foo-column", "bar-value", 0)
        |> Mutations.set_cell("otherFamily", "bar-column", "other-value", 0)

      second_mutation =
        Mutations.build("Test#2")
        |> Mutations.set_cell("cf1", "foo-column", "bar-value", 0)
        |> Mutations.set_cell("cf2", "bar-column", "foo-value", 0)
        |> Mutations.set_cell("otherFamily", "foo-column", "other-value", 0)

      foo_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "foo-column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "bar-value"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "otherFamily"},
            label: "",
            qualifier: %BytesValue{value: "foo-column"},
            row_key: "Test#2",
            timestamp: 0,
            value: "other-value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "foo-column"},
            row_key: "Test#2",
            timestamp: 0,
            value: "bar-value"
          }
        ]
      }

      bar_expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "otherFamily"},
            label: "",
            qualifier: %BytesValue{value: "bar-column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "other-value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "bar-column"},
            row_key: "Test#1",
            timestamp: 0,
            value: "foo-value"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "bar-column"},
            row_key: "Test#2",
            timestamp: 0,
            value: "foo-value"
          }
        ]
      }

      {:ok, _} =
        [first_mutation, second_mutation]
        |> MutateRows.build()
        |> MutateRows.mutate()

      {:ok, foo_result} =
        ReadRows.build()
        |> RowFilter.column_qualifier_regex("foo-?\\w{0,}")
        |> ReadRows.read()

      {:ok, bar_result} =
        ReadRows.build()
        |> RowFilter.column_qualifier_regex("bar-?\\w{0,}")
        |> ReadRows.read()

      assert foo_result == foo_expected
      assert bar_result == bar_expected
    end
  end

  describe "RowFilter.column_range" do
    setup do
      seed_range("Test#1")
    end

    test "should properly filter inclusive range in single row" do
      range = {"column2", "column4"}

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column4"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value4"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value3"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value2"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.column_range("cf1", range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter inclusive range in multiple rows" do
      seed_range("Test#2")

      range = {"column2", "column4"}

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column4"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value4"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value3"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value2"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column4"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value4"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value3"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value2"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.column_range("cf1", range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter exclusive range in single row" do
      range = {"column2", "column4", false}

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value3"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.column_range("cf1", range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter exclusive range in multiple rows" do
      seed_range("Test#2")

      range = {"column2", "column4", false}

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: "Test#1",
            timestamp: 0,
            value: "value3"
          }
        ],
        "Test#2" => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: "Test#2",
            timestamp: 0,
            value: "value3"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.column_range("cf1", range)
        |> ReadRows.read()

      assert result == expected
    end
  end

  describe "RowFilter.timestamp_range" do
    setup do
      seed_timestamp_range("Test#1")
    end

    test "should properly filter start timestamp in single row" do
      range = [start_timestamp: 2000]

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 2000,
            value: "value2"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 3000,
            value: "value3"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 4000,
            value: "value4"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 2000,
            value: "value2"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 3000,
            value: "value3"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 4000,
            value: "value4"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.timestamp_range(range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter end timestamp in single row" do
      range = [end_timestamp: 2000]

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 1000,
            value: "value1"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 1000,
            value: "value1"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.timestamp_range(range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter timestamp range in single row" do
      range = [start_timestamp: 2000, end_timestamp: 4000]

      expected = %{
        "Test#1" => [
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 2000,
            value: "value2"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf2"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 3000,
            value: "value3"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 2000,
            value: "value2"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: "Test#1",
            timestamp: 3000,
            value: "value3"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.timestamp_range(range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter start timestamp in multiple rows" do
      seed_timestamp_range("Test#2")

      range = [start_timestamp: 2000]

      expected =
        ["Test#1", "Test#2"]
        |> Enum.reduce(%{}, fn row_key, accum ->
          Map.put(accum, row_key, [
            %ReadCell{
              family_name: %StringValue{value: "cf2"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 2000,
              value: "value2"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf2"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 3000,
              value: "value3"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf2"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 4000,
              value: "value4"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf1"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 2000,
              value: "value2"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf1"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 3000,
              value: "value3"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf1"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 4000,
              value: "value4"
            }
          ])
        end)

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.timestamp_range(range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter end timestamp in multiple rows" do
      seed_timestamp_range("Test#2")

      range = [end_timestamp: 2000]

      expected =
        ["Test#1", "Test#2"]
        |> Enum.reduce(%{}, fn row_key, accum ->
          Map.put(accum, row_key, [
            %ReadCell{
              family_name: %StringValue{value: "cf2"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 1000,
              value: "value1"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf1"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 1000,
              value: "value1"
            }
          ])
        end)

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.timestamp_range(range)
        |> ReadRows.read()

      assert result == expected
    end

    test "should properly filter timestamp range in multiple rows" do
      seed_timestamp_range("Test#2")

      range = [start_timestamp: 2000, end_timestamp: 4000]

      expected =
        ["Test#1", "Test#2"]
        |> Enum.reduce(%{}, fn row_key, accum ->
          Map.put(accum, row_key, [
            %ReadCell{
              family_name: %StringValue{value: "cf2"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 2000,
              value: "value2"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf2"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 3000,
              value: "value3"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf1"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 2000,
              value: "value2"
            },
            %ReadCell{
              family_name: %StringValue{value: "cf1"},
              label: "",
              qualifier: %BytesValue{value: "column1"},
              row_key: row_key,
              timestamp: 3000,
              value: "value3"
            }
          ])
        end)

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.timestamp_range(range)
        |> ReadRows.read()

      assert result == expected
    end
  end

  describe "RowFilter.pass_all()" do
    test "should let all values from a row pass through", context do
      [row_key | _rest] = context.row_keys

      {:ok, _} =
        Mutations.build(row_key)
        |> Mutations.set_cell("cf1", "column", "value", 0)
        |> MutateRow.mutate()

      expected = %{
        row_key => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column"},
            row_key: row_key,
            timestamp: 0,
            value: "value"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.pass_all()
        |> ReadRows.read()

      assert result == expected
    end
  end

  describe "RowFilter.strip_value_transformer()" do
    test "should replace values with empty strings", context do
      [row_key | _rest] = context.row_keys

      {:ok, _} =
        Mutations.build(row_key)
        |> Mutations.set_cell("cf1", "column1", "value", 0)
        |> Mutations.set_cell("cf1", "column2", "value", 0)
        |> Mutations.set_cell("cf1", "column3", "value", 0)
        |> MutateRow.mutate()

      expected = %{
        row_key => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column3"},
            row_key: row_key,
            timestamp: 0,
            value: ""
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column2"},
            row_key: row_key,
            timestamp: 0,
            value: ""
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "",
            qualifier: %BytesValue{value: "column1"},
            row_key: row_key,
            timestamp: 0,
            value: ""
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.strip_value_transformer()
        |> ReadRows.read()

      assert result == expected
    end
  end

  describe "RowFilter.cells_per_row()" do
    test "should limit the number of cells in a returned row", context do
      [row_key | _rest] = context.row_keys

      {:ok, _} =
        Mutations.build(row_key)
        |> Mutations.set_cell("cf1", "column1", "value", 4000)
        |> Mutations.set_cell("cf2", "column2", "value", 1000)
        |> Mutations.set_cell("cf1", "column2", "value", 1000)
        |> Mutations.set_cell("cf2", "column3", "value", 2000)
        |> MutateRow.mutate()

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.cells_per_row(2)
        |> ReadRows.read()

      result_size =
        result
        |> Map.values()
        |> List.flatten()
        |> length()

      assert result_size == 2
    end
  end

  describe "RowFilter.apply_label_transformer()" do
    test "should apply label to cells", context do
      [row_key | _rest] = context.row_keys

      {:ok, _} =
        Mutations.build(row_key)
        |> Mutations.set_cell("cf1", "column1", "value", 0)
        |> Mutations.set_cell("cf1", "column2", "value", 0)
        |> Mutations.set_cell("cf1", "column3", "value", 0)
        |> MutateRow.mutate()

      expected = %{
        row_key => [
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "label",
            qualifier: %BytesValue{value: "column3"},
            row_key: row_key,
            timestamp: 0,
            value: "value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "label",
            qualifier: %BytesValue{value: "column2"},
            row_key: row_key,
            timestamp: 0,
            value: "value"
          },
          %ReadCell{
            family_name: %StringValue{value: "cf1"},
            label: "label",
            qualifier: %BytesValue{value: "column1"},
            row_key: row_key,
            timestamp: 0,
            value: "value"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.apply_label_transformer("label")
        |> ReadRows.read()

      assert result == expected
    end
  end

  describe "RowFilter.chain" do
    test "should properly apply a chain of filters", context do
      seed_values(context)
      seed_multiple_values(3)

      filters = [
        RowFilter.row_key_regex("^Test#1"),
        RowFilter.cells_per_column(1)
      ]

      expected = %{
        "Test#1" => [
          %Bigtable.ChunkReader.ReadCell{
            family_name: %Google.Protobuf.StringValue{value: "cf1"},
            label: "",
            qualifier: %Google.Protobuf.BytesValue{value: "column"},
            row_key: "Test#1",
            timestamp: 3000,
            value: "3"
          }
        ]
      }

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.chain(filters)
        |> ReadRows.read()

      assert result == expected
    end
  end

  defp seed_multiple_values(num) do
    mutations =
      Enum.map(1..num, fn i ->
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column", to_string(i), 1000 * i)
      end)

    mutations
    |> MutateRows.build()
    |> MutateRows.mutate()
  end

  defp seed_timestamp_range(row_key) do
    {:ok, _} =
      Mutations.build(row_key)
      |> Mutations.set_cell("cf1", "column1", "value1", 1000)
      |> Mutations.set_cell("cf1", "column1", "value2", 2000)
      |> Mutations.set_cell("cf1", "column1", "value3", 3000)
      |> Mutations.set_cell("cf1", "column1", "value4", 4000)
      |> Mutations.set_cell("cf2", "column1", "value1", 1000)
      |> Mutations.set_cell("cf2", "column1", "value2", 2000)
      |> Mutations.set_cell("cf2", "column1", "value3", 3000)
      |> Mutations.set_cell("cf2", "column1", "value4", 4000)
      |> MutateRow.build()
      |> MutateRow.mutate()

    :ok
  end

  defp seed_range(row_key) do
    {:ok, _} =
      Mutations.build(row_key)
      |> Mutations.set_cell("cf1", "column1", "value1", 0)
      |> Mutations.set_cell("cf1", "column2", "value2", 0)
      |> Mutations.set_cell("cf1", "column3", "value3", 0)
      |> Mutations.set_cell("cf1", "column4", "value4", 0)
      |> Mutations.set_cell("cf1", "column5", "value5", 0)
      |> MutateRow.build()
      |> MutateRow.mutate()

    :ok
  end

  defp seed_values(context) do
    Enum.each(context.row_keys, fn key ->
      {:ok, _} =
        Mutations.build(key)
        |> Mutations.set_cell("cf1", "column", "value", 0)
        |> MutateRow.build()
        |> MutateRow.mutate()

      :ok
    end)
  end
end

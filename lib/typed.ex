defmodule Bigtable.Typed do
  alias Bigtable.ByteString

  def test_parse() do
    type_spec = %{
      family_one: %{
        one_a: :integer,
        one_b: :boolean,
        one_nested: %{
          one_nested_a: :integer,
          one_nested_b: :boolean
        },
        one_double_nested: %{
          one_double_nested_a: %{
            a: :integer
          }
        }
      },
      family_two: %{
        two_a: :integer,
        two_b: :boolean
      }
    }

    chunks = [
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_one"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "one_a"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(1),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_one"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "one_b"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(true),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_one"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "one_nested.one_nested_a"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(1),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_one"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "one_nested.one_nested_b"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(true),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_one"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "one_double_nested.one_double_nested_a.a"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(1),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_two"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "two_a"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(1),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "family_two"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "two_b"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(true),
        value_size: 0
      }
    ]

    parse_typed(type_spec, chunks)
  end

  def test_mut do
    map = %{
      family_a: %{
        id: "id#123",
        age: 32,
        nested: %{
          first: "first",
          second: "second"
        },
        double: %{
          nested: %{
            first: true,
            second: 2
          }
        }
      }
    }

    create_mutations("id#123", map)
  end

  def create_mutations(row_key, map) do
    entry = Bigtable.Mutations.build(row_key)

    Enum.reduce(map, entry, fn {k, v}, accum ->
      apply_mutations(v, accum, to_string(k))
    end)
  end

  defp apply_mutations(map, entry, family_name, parent_key \\ nil) do
    Enum.reduce(map, entry, fn {k, v}, accum ->
      case is_map(v) do
        true ->
          column_qualifier =
            case parent_key do
              nil -> to_string(k)
              key -> "#{key}.#{to_string(k)}"
            end

          apply_mutations(v, accum, family_name, column_qualifier)

        false ->
          column_qualifier =
            case parent_key do
              nil -> to_string(k)
              key -> "#{key}.#{to_string(k)}"
            end

          accum
          |> Bigtable.Mutations.set_cell(family_name, column_qualifier, v)
      end
    end)
  end

  def parse_typed(type_spec, chunks) do
    Enum.reduce(chunks, %{}, fn chunk, accum ->
      family_key = String.to_atom(chunk.family_name.value)
      family_spec = Map.fetch!(type_spec, family_key)

      field_name = chunk.qualifier.value
      value = chunk.value
      parse_from_spec(family_spec, field_name, value, accum)
    end)
  end

  def parse_from_spec(type_spec, field_name, value, accum) do
    case String.contains?(field_name, ".") do
      true ->
        [parent_name | rest] = String.split(field_name, ".")
        parent_key = String.to_atom(parent_name)

        prev_child = Map.get(accum, parent_key, %{})
        child_type_spec = Map.fetch!(type_spec, parent_key)
        child_qualifier = Enum.join(rest, ".")

        child_value = parse_from_spec(child_type_spec, child_qualifier, value, prev_child)

        Map.put(accum, parent_key, child_value)

      false ->
        key = String.to_atom(field_name)
        type = Map.get(type_spec, key)
        value = ByteString.parse_value(type, value)
        Map.put(accum, key, value)
    end
  end
end

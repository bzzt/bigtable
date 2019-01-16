defmodule Bigtable.Typed do
  alias Bigtable.ByteString

  def test_parse() do
    type_spec = %{
      id: :binary,
      age: :integer,
      nested: %{
        first: :binary,
        second: :binary
      },
      double: %{
        nested: %{
          first: :boolean,
          second: :integer
        }
      },
      triple: %{
        double: %{
          nested: %{
            first: :boolean,
            second: :integer
          }
        }
      }
    }

    chunks = [
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "id"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string("id#1"),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "age"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(32),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "nested.first"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string("first"),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "nested.second"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: "second",
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "double.nested.first"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(true),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "double.nested.second"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(2),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "triple.double.nested.first"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(true),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "triple.double.nested.second"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: ByteString.to_byte_string(2),
        value_size: 0
      }
    ]

    parse_typed(type_spec, chunks)
  end

  def test_mut do
    map = %{
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

    create_mutations("id#123", map)
  end

  def create_mutations(row_key, map, parent_key \\ nil) do
    Enum.reduce(map, [], fn {k, v}, accum ->
      case is_map(v) do
        true ->
          column_qualifier =
            case parent_key do
              nil -> to_string(k)
              key -> "#{key}.#{to_string(k)}"
            end

          child_mutations = create_mutations(row_key, v, column_qualifier)
          accum ++ child_mutations

        false ->
          column_qualifier =
            case parent_key do
              nil -> to_string(k)
              key -> "#{key}.#{to_string(k)}"
            end

          mutation =
            Bigtable.Mutations.build(row_key)
            |> Bigtable.Mutations.set_cell("ride", column_qualifier, v)

          [mutation | accum]
      end
    end)
  end

  def parse_typed(type_spec, chunks) do
    Enum.reduce(chunks, %{}, fn chunk, accum ->
      field_name = chunk.qualifier.value
      value = chunk.value
      parse_from_spec(type_spec, field_name, value, accum)
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

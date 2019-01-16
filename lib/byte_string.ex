defmodule Bigtable.ByteString do
  @doc """
  %{id: :string, age: integer}

  [
    %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
    family_name: %Google.Protobuf.StringValue{value: "ride"},
    labels: [],
    qualifier: %Google.Protobuf.BytesValue{value: "id"},
    row_key: "Row#123",
    row_status: {:commit_row, true},
    timestamp_micros: 1547637474930000,
    value: "foo",
    value_size: 0
  },
  %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
    family_name: %Google.Protobuf.StringValue{value: "ride"},
    labels: [],
    qualifier: %Google.Protobuf.BytesValue{value: "age"},
    row_key: "Row#123",
    row_status: {:commit_row, true},
    timestamp_micros: 1547637474930000,
    value: "foo",
    value_size: 0
  }
  ]
  %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
    family_name: %Google.Protobuf.StringValue{value: "ride"},
    labels: [],
    qualifier: %Google.Protobuf.BytesValue{value: "id"},
    row_key: "Row#123",
    row_status: {:commit_row, true},
    timestamp_micros: 1547637474930000,
    value: "foo",
    value_size: 0
  }
  """

  def test() do
    type_spec = %{
      id: :binary,
      age: :integer,
      nested: %{
        first: :binary,
        second: :boolean
      }
    }

    cells = [
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "id"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: to_byte_string("id#1"),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "age"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: to_byte_string(32),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "nested.first"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: to_byte_string("first"),
        value_size: 0
      },
      %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
        family_name: %Google.Protobuf.StringValue{value: "ride"},
        labels: [],
        qualifier: %Google.Protobuf.BytesValue{value: "nested.second"},
        row_key: "Row#123",
        row_status: {:commit_row, true},
        timestamp_micros: 1_547_637_474_930_000,
        value: to_byte_string(false),
        value_size: 0
      }
    ]

    Enum.reduce(cells, %{}, fn chunk, accum ->
      IO.inspect(chunk)
      IO.inspect(accum)
      field_name = chunk.qualifier.value

      case String.contains?(field_name, ".") do
        true ->
          [parent_name, second_name] = String.split(field_name, ".")
          parent_key = String.to_atom(parent_name)
          prev_nested = Map.get(accum, parent_key, %{})

          Map.put(
            accum,
            parent_key,
            parse_with_type(Map.get(type_spec, parent_key), second_name, chunk.value, prev_nested)
          )

        false ->
          # key = String.to_atom(field_name)
          # parsed_value = parse_value(Map.get(type, key), chunk.value)
          # Map.put(accum, key, parsed_value)
          parse_with_type(type_spec, field_name, chunk.value, accum)
      end
    end)
  end

  def parse_with_type(type_spec, field_name, value, accum \\ %{}) do
    key = String.to_atom(field_name)
    type = Map.get(type_spec, key)
    parsed = parse_value(type, value)
    Map.put(accum, key, parsed)
  end

  def parse_value(type, byte_string) do
    case type do
      :integer ->
        <<v::integer-signed-32>> = byte_string
        v

      :float ->
        <<v::signed-little-float-64>> = byte_string
        v

      :binary ->
        to_string(byte_string)

      :boolean ->
        case parse_value(:integer, byte_string) do
          0 -> false
          1 -> true
        end
    end
  end

  def to_byte_string(value) do
    case value do
      v when is_binary(v) ->
        v

      v when is_boolean(v) ->
        case v do
          true -> to_byte_string(1)
          false -> to_byte_string(0)
        end

      v when is_integer(v) ->
        <<v::integer-signed-32>>

      v when is_float(v) ->
        <<v::signed-little-float-64>>
    end
  end
end

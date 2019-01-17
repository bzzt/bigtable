defmodule Bigtable.Schema do
  alias Bigtable.ByteString

  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro type(do: block) do
    {_, _, fields} = block

    field_list =
      Keyword.new(
        Enum.reduce(fields, [], fn field, accum ->
          case field do
            {:field, _, [key, value]} ->
              [{key, value} | accum]

            _ ->
              accum
          end
        end)
      )

    quote do
      defstruct unquote(field_list)

      def parse(chunks) do
        Bigtable.Typed.parse_typed(%__MODULE__{}, chunks)
      end

      def test_chunks do
        chunks = [
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "ride"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "first"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(1),
            value_size: 0
          },
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "ride"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "second"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(true),
            value_size: 0
          },
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "ride"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "child.a"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(1),
            value_size: 0
          },
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "ride"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "child.b"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(2),
            value_size: 0
          }
        ]
      end
    end
  end

  defmacro field(key, value) do
    IO.inspect(key)
    IO.inspect(value)
  end
end

defmodule ChildSchema do
  use Bigtable.Schema

  type do
    field(:a, :integer)
    field(:b, :integer)
  end
end

defmodule TestSchema do
  use Bigtable.Schema

  type do
    field(:first, :integer)
    field(:second, :boolean)
    field(:child, %ChildSchema{})
  end
end

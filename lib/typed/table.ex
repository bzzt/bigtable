defmodule Bigtable.Schema do
  alias Bigtable.ByteString

  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro type(do: block) do
    {_, _, families} = block

    family_list =
      Keyword.new(
        Enum.reduce(families, [], fn family, accum ->
          case family do
            {:family, _, [key, value]} ->
              [{key, value} | accum]

            _ ->
              accum
          end
        end)
      )

    IO.inspect(families)
    IO.inspect(family_list)

    Enum.map(family_list, fn family ->
      nil
    end)

    quote do
      defstruct unquote(family_list)

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

  defmacro family(name, do: block) do
    {_, _, columns} = block

    column_list =
      Keyword.new(
        Enum.reduce(columns, [], fn field, accum ->
          case field do
            {:column, _, [key, value]} ->
              [{key, value} | accum]

            _ ->
              accum
          end
        end)
      )

    quote do
      defmodule unquote(name) do
        defstruct unquote(column_list)
      end
    end
  end

  defmacro column(key, value) do
    IO.inspect(key)
    IO.inspect(value)
  end
end

# defmodule ChildSchema do
#   use Bigtable.Schema

#   type do
#     field(:a, :integer)
#     field(:b, :integer)
#   end
# end

defmodule TestSchema do
  use Bigtable.Schema

  type do
    family :ride do
      column(:first, :integer)
      column(:second, :boolean)
    end

    family :second_family do
      column(:first, :integer)
      column(:second, :boolean)
    end
  end
end

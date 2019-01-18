defmodule Bigtable.Schema do
  alias Bigtable.ByteString

  defp list_from_block(block, to_match) do
    Enum.reduce(block, [], fn value, accum ->
      with {block_type, _, [k, v]} <- value do
        case block_type == to_match do
          true -> [{k, v} | accum]
          false -> accum
        end
      end
    end)
  end

  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro type(do: block) do
    {_, _, columns} = block
    column_list = list_from_block(columns, :column)

    quote do
      defstruct unquote(column_list)

      def type() do
        %__MODULE__{}
      end
    end
  end

  defmacro row(do: block) do
    {_, _, families} = block

    family_list = list_from_block(families, :family)

    families_with_columns =
      Enum.map(family_list, fn family ->
        {family_name, [do: {:__block__, [], columns}]} = family
        column_list = list_from_block(columns, :column)

        {family_name, Map.new(column_list)}
      end)

    quote do
      defstruct unquote(Macro.escape(families_with_columns))

      def parse(row) do
        Bigtable.Typed.parse_typed(__MODULE__.type(), row)
      end

      def type() do
        %__MODULE__{}
      end

      def test_row do
        chunks = [
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "first_family"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "first_first"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(1),
            value_size: 0
          },
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "first_family"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "first_second"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(true),
            value_size: 0
          },
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "second_family"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "second_first"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(2),
            value_size: 0
          },
          %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
            family_name: %Google.Protobuf.StringValue{value: "second_family"},
            labels: [],
            qualifier: %Google.Protobuf.BytesValue{value: "second_second"},
            row_key: "Row#123",
            row_status: {:commit_row, true},
            timestamp_micros: 1_547_637_474_930_000,
            value: ByteString.to_byte_string(false),
            value_size: 0
          }
        ]

        %Google.Bigtable.V2.ReadRowsResponse{
          chunks: chunks,
          last_scanned_row_key: ""
        }
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
  end
end

defmodule TestChild do
  use Bigtable.Schema

  type do
    column(:nested_first, :integer)
    column(:nested_second, :boolean)
  end
end

defmodule TestSchema do
  use Bigtable.Schema

  row do
    family(:first_family) do
      column(:first_first, :integer)
      column(:first_second, :boolean)
      column(:nested, TestChild.type())
    end

    family :second_family do
      column(:second_first, :integer)
      column(:second_second, :boolean)
    end
  end
end

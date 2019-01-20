defmodule Bigtable.ByteString do
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

      :list ->
        Poison.decode!(byte_string)
    end
  end

  @spec to_byte_string(false | nil | true | binary() | maybe_improper_list() | number()) ::
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | byte(),
              binary() | []
            )
  def to_byte_string(value) do
    # Poison.encode!(value)
    case value do
      v when is_nil(v) ->
        ""

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

      v when is_list(v) ->
        Poison.encode!(v)
    end
  end
end

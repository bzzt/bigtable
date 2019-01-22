defmodule Bigtable.ByteString do
  @moduledoc false

  @spec parse_value(:integer, binary()) :: integer()
  def parse_value(:integer, byte_string) do
    <<v::integer-signed-32>> = byte_string
    v
  end

  @spec parse_value(:float, binary()) :: float()
  def parse_value(:float, byte_string) do
    <<v::signed-little-float-64>> = byte_string
    v
  end

  @spec parse_value(:string, binary()) :: binary()
  def parse_value(:string, byte_string) do
    to_string(byte_string)
  end

  @spec parse_value(:map, binary()) :: map()
  def parse_value(:map, byte_string) do
    Poison.decode!(byte_string)
  end

  @spec parse_value(:list, binary()) :: list()
  def parse_value(:list, byte_string) do
    Poison.decode!(byte_string)
  end

  @spec to_byte_string(nil) :: binary()
  def to_byte_string(v) when is_nil(v), do: ""

  @spec to_byte_string(binary()) :: binary()
  def to_byte_string(v) when is_binary(v), do: v

  @spec to_byte_string(boolean()) :: binary()
  def to_byte_string(v) when is_boolean(v) do
    case v do
      true -> to_byte_string(1)
      false -> to_byte_string(0)
    end
  end

  @spec to_byte_string(integer()) :: binary()
  def to_byte_string(v) when is_integer(v), do: <<v::integer-signed-32>>

  @spec to_byte_string(float()) :: binary()
  def to_byte_string(v) when is_float(v), do: <<v::signed-little-float-64>>

  @spec to_byte_string(list() | map()) :: binary()
  def to_byte_string(v) when is_list(v) or is_map(v), do: Poison.encode!(v)
end

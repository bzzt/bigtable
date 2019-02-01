defmodule Bigtable.ByteString do
  @moduledoc false

  def parse_value(_, ""), do: nil
  def parse_value(_, nil), do: nil

  def parse_value(_, "true"), do: true
  def parse_value(_, "false"), do: false

  @spec parse_value(:integer, binary()) :: integer()
  def parse_value(:integer, byte_string) do
    Integer.parse(byte_string)
  end

  @spec parse_value(:float, binary()) :: float()
  def parse_value(:float, byte_string) do
    Float.parse(byte_string)
  end

  @spec parse_value(:string, binary()) :: binary()
  def parse_value(:string, byte_string) do
    byte_string
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

  @spec to_byte_string(list() | map()) :: binary()
  def to_byte_string(v) when is_list(v) or is_map(v), do: Poison.encode!(v)

  def to_byte_string(v), do: to_string(v)
end

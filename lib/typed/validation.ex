defmodule Bigtable.Typed.Validation do
  def validate_map!(type_spec, map) do
    Enum.each(map, fn {k, v} ->
      if Map.get(type_spec, k) != nil do
        case typed_map?(k, v) do
          true ->
            nested_type = Map.get(type_spec, k)
            nested_map = Map.get(map, k)
            validate_map!(nested_type, nested_map)

          false ->
            type = Map.get(type_spec, k)

            type
            |> validate!(v, map)
        end
      else
        :ok
      end
    end)
  end

  def validate!(nil, _, _), do: :ok

  def validate!(type, value, parent) do
    unless valid?(type, value) do
      throw(
        "Value #{inspect(value)} does not conform to type #{inspect(type)} in #{inspect(parent)}"
      )
    end

    :ok
  end

  def typed_map?(key, value), do: key != :map and is_map(value)

  def valid?(_, nil), do: true

  def valid?(:string, v), do: is_binary(v)
  def valid?(:integer, v), do: is_integer(v)
  def valid?(:float, v), do: is_float(v)
  def valid?(:list, v), do: is_list(v)
  def valid?(:map, v), do: is_map(v)
end

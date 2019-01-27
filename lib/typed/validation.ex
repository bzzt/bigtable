defmodule Bigtable.Typed.Validation do
  @moduledoc false
  @spec validate_map!(map(), map()) :: :ok
  def validate_map!(type_spec, map) do
    Enum.each(map, fn {k, v} ->
      if Map.get(type_spec, k) != nil do
        type = Map.get(type_spec, k)

        case typed_map?(type, v) do
          true ->
            nested_map = Map.get(map, k)
            validate_map!(type, nested_map)

          false ->
            type
            |> validate!(v, map)
        end
      else
        :ok
      end
    end)
  end

  @spec validate!(nil | atom(), any(), map()) :: :ok
  defp validate!(nil, _, _), do: :ok

  defp validate!(type, value, parent) do
    unless valid?(type, value) do
      raise(
        RuntimeError,
        "Value #{inspect(value)} does not conform to type #{inspect(type)} in #{inspect(parent)}"
      )
    end

    :ok
  end

  @spec typed_map?(map(), map()) :: true
  defp typed_map?(type, value) when is_map(type) and is_map(value), do: true
  @spec typed_map?(atom(), any()) :: false
  defp typed_map?(_, _), do: false

  @spec valid?(atom(), any()) :: boolean()
  def valid?(_, nil), do: true
  def valid?(:boolean, v), do: is_boolean(v)
  def valid?(:string, v), do: is_binary(v)
  def valid?(:integer, v), do: is_integer(v)
  def valid?(:float, v), do: is_float(v) or is_integer(v)
  def valid?(:list, v), do: is_list(v)
  def valid?(:map, v), do: is_map(v)
end

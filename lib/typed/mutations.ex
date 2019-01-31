defmodule Bigtable.Typed.Mutations do
  @moduledoc false
  @spec create_mutations(binary(), map(), map()) :: Google.Bigtable.V2.MutateRowsRequest.Entry.t()
  def create_mutations(row_key, type_spec, map) do
    entry = Bigtable.Mutations.build(row_key)

    Enum.reduce(map, entry, fn {k, v}, accum ->
      case Map.get(type_spec, k) do
        nil ->
          accum

        type ->
          apply_mutations(type, v, accum, to_string(k))
      end
    end)
  end

  # TODO: Make all fields on map type nil if root value is nil

  @spec apply_mutations(
          map(),
          Google.Bigtable.V2.MutateRowsRequest.Entry.t(),
          binary(),
          binary() | nil
        ) :: Google.Bigtable.V2.MutateRowsRequest.Entry.t()
  defp apply_mutations(type_spec, map, entry, family_name, parent_key \\ nil) do
    Enum.reduce(map, entry, fn {k, v}, accum ->
      column_qualifier = column_qualifier(parent_key, k)

      case Map.get(type_spec, k) do
        nil ->
          accum

        type when is_map(type) ->
          nested_map(type, v, accum, family_name, column_qualifier)

        _ ->
          accum
          |> Bigtable.Mutations.set_cell(family_name, column_qualifier, v)
      end
    end)
  end

  defp nested_map(type, value, accum, family_name, column_qualifier) do
    if value == nil or value == "" do
      niled_map = nil_values(type)
      apply_mutations(type, niled_map, accum, family_name, column_qualifier)
    else
      apply_mutations(type, value, accum, family_name, column_qualifier)
    end
  end

  defp nil_values(type_spec) do
    Enum.reduce(type_spec, %{}, fn {k, v}, accum ->
      if is_map(v) do
        Map.put(accum, k, nil_values(v))
      else
        Map.put(accum, k, "")
      end
    end)
  end

  @spec column_qualifier(binary() | nil, binary()) :: binary()
  defp column_qualifier(parent_key, key) do
    case parent_key do
      nil -> to_string(key)
      parent -> "#{parent}.#{to_string(key)}"
    end
  end
end

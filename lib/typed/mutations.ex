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

  @spec apply_mutations(
          map(),
          Google.Bigtable.V2.MutateRowsRequest.Entry.t(),
          binary(),
          binary() | nil
        ) :: Google.Bigtable.V2.MutateRowsRequest.Entry.t()
  defp apply_mutations(type_spec, map, entry, family_name, parent_key \\ nil) do
    Enum.reduce(map, entry, fn {k, v}, accum ->
      column_qualifier = column_qualifier(parent_key, k)

      if Map.get(type_spec, k) == nil do
        accum
      else
        case is_map(v) do
          true ->
            child_spec = Map.get(type_spec, k)
            apply_mutations(child_spec, v, accum, family_name, column_qualifier)

          false ->
            accum
            |> Bigtable.Mutations.set_cell(family_name, column_qualifier, v)
        end
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

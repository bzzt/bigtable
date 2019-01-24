defmodule Bigtable.Typed.Update do
  @moduledoc false
  alias Bigtable.{MutateRows, Typed}
  alias Typed.{Utils, Validation}

  def update(type_spec, maps, row_prefix, update_patterns) do
    mutations = mutations_from_maps(type_spec, maps, row_prefix, update_patterns)

    mutations
    |> MutateRows.mutate()
  end

  @spec mutations_from_maps(map(), [map()], binary(), [binary()]) ::
          Google.Bigtable.V2.MutateRows.Entry.t()
  def mutations_from_maps(type_spec, maps, row_prefix, update_patterns) do
    Enum.each(maps, &Validation.validate_map!(type_spec, &1))

    mutations = Enum.map(maps, &mutations_from_map(type_spec, &1, row_prefix, update_patterns))

    mutations
    |> List.flatten()
    |> MutateRows.build()
  end

  # TODO: Only create mutations once and apply to all keys

  @spec mutations_from_map(map(), map(), binary(), [binary()]) :: [
          Google.Bigtable.V2.MutateRowsRequest.Entry.t()
        ]
  defp mutations_from_map(type_spec, map, row_prefix, update_patterns) do
    Enum.map(update_patterns, fn pattern ->
      properties = Utils.row_key_properties(pattern)

      properties
      |> Utils.build_update_key(row_prefix, map)
      |> Typed.create_mutations(type_spec, map)
    end)
  end
end

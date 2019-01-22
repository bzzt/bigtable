defmodule Bigtable.Typed.Update do
  alias Bigtable.{MutateRows, Typed}
  alias Typed.Utils

  def mutations_from_maps(maps, row_prefix, update_patterns) do
    Enum.map(maps, &mutations_from_map(&1, row_prefix, update_patterns))
    |> List.flatten()
    |> MutateRows.build()
    |> MutateRows.mutate()
  end

  defp mutations_from_map(map, row_prefix, update_patterns) do
    Enum.map(update_patterns, fn pattern ->
      Utils.row_key_properties(pattern)
      |> Utils.build_update_key(row_prefix, map)
      |> Typed.create_mutations(map)
    end)
  end
end

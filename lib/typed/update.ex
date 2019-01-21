defmodule Bigtable.Typed.Update do
  def mutations_from_maps(maps, row_prefix, update_patterns) do
    Enum.map(maps, &mutations_from_map(&1, row_prefix, update_patterns))
  end

  defp mutations_from_map(map, row_prefix, update_patterns) do
    Enum.map(update_patterns, fn pattern ->
      row_key_properties(pattern)
      |> build_key(row_prefix, map)
      |> Bigtable.Typed.create_mutations(map)
    end)
  end

  defp row_key_properties(update_pattern) do
    String.split(update_pattern, "#")
  end

  defp build_key(access_patterns, prefix, map) do
    access_patterns
    |> Enum.reduce("#{prefix}", fn pattern, row_key ->
      [column_family | rest] = String.split(pattern, ".") |> Enum.map(&String.to_atom/1)

      value = build_lens(column_family, rest) |> Lens.one!(map)

      if(is_nil(value)) do
        throw("Unable to find key #{pattern} on #{inspect(map)}")
      end

      row_key <> "##{value}"
    end)
  end

  defp build_lens(root_key, access_keys) do
    Enum.reduce(access_keys, Lens.key(root_key), fn key, lens ->
      lens |> Lens.key(key)
    end)
  end
end

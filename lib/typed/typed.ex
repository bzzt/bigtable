defmodule Bigtable.Typed do
  alias Bigtable.ByteString

  def create_mutations(row_key, map) do
    entry = Bigtable.Mutations.build(row_key)

    Enum.reduce(map, entry, fn {k, v}, accum ->
      apply_mutations(v, accum, to_string(k))
    end)
  end

  defp apply_mutations(map, entry, family_name, parent_key \\ nil) do
    Enum.reduce(map, entry, fn {k, v}, accum ->
      case is_map(v) do
        true ->
          column_qualifier =
            case parent_key do
              nil -> to_string(k)
              key -> "#{key}.#{to_string(k)}"
            end

          apply_mutations(v, accum, family_name, column_qualifier)

        false ->
          column_qualifier =
            case parent_key do
              nil -> to_string(k)
              key -> "#{key}.#{to_string(k)}"
            end

          accum
          |> Bigtable.Mutations.set_cell(family_name, column_qualifier, v)
      end
    end)
  end

  def parse_typed(type_spec, row) do
    initial = %{last_family: nil, parsed: %{}}

    %{parsed: parsed} =
      Enum.reduce(row.chunks, initial, fn chunk, %{last_family: last_family, parsed: parsed} ->
        family_key =
          case is_map(chunk.family_name) do
            false -> last_family
            true -> String.to_atom(chunk.family_name.value)
          end

        family_spec = Map.fetch!(type_spec, family_key)

        column_name = chunk.qualifier.value
        column_value = chunk.value

        next_parsed = parse_from_spec(family_spec, column_name, column_value, parsed)
        %{parsed: next_parsed, last_family: family_key}
      end)

    parsed
  end

  def parse_from_spec(type_spec, field_name, value, accum) do
    case String.contains?(field_name, ".") do
      true ->
        [parent_name | rest] = String.split(field_name, ".")
        parent_key = String.to_atom(parent_name)

        prev_child = Map.get(accum, parent_key, %{})
        child_type_spec = Map.fetch!(type_spec, parent_key)
        child_qualifier = Enum.join(rest, ".")

        child_value = parse_from_spec(child_type_spec, child_qualifier, value, prev_child)

        Map.put(accum, parent_key, child_value)

      false ->
        key = String.to_atom(field_name)
        type = Map.get(type_spec, key)
        value = ByteString.parse_value(type, value)
        Map.put(accum, key, value)
    end
  end
end

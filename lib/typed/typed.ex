defmodule Bigtable.Typed do
  alias Bigtable.ByteString

  @spec create_mutations(binary(), map()) :: Google.Bigtable.V2.MutateRowsRequest.Entry.t()

  def create_mutations(row_key, map) do
    entry = Bigtable.Mutations.build(row_key)

    Enum.reduce(map, entry, fn {k, v}, accum ->
      apply_mutations(v, accum, to_string(k))
    end)
  end

  @spec apply_mutations(
          map(),
          Google.Bigtable.V2.MutateRowsRequest.Entry.t(),
          binary(),
          binary() | nil
        ) :: Google.Bigtable.V2.MutateRowsRequest.Entry.t()
  defp apply_mutations(map, entry, family_name, parent_key \\ nil) do
    Enum.reduce(map, entry, fn {k, v}, accum ->
      column_qualifier = column_qualifier(parent_key, k)

      case is_map(v) do
        true ->
          apply_mutations(v, accum, family_name, column_qualifier)

        false ->
          accum
          |> Bigtable.Mutations.set_cell(family_name, column_qualifier, v)
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

  def parse_result(result, type_spec) do
    result
    |> Enum.map(fn {:ok, rows} -> rows.chunks end)
    |> List.flatten()
    |> Bigtable.Typed.group_by_row_key()
    |> Enum.map(&parse_typed(type_spec, &1))
  end

  def parse_typed(type_spec, chunks) do
    initial = %{last_family: nil, parsed: %{}}

    %{parsed: parsed} =
      Enum.reduce(chunks, initial, fn chunk, %{last_family: last_family, parsed: parsed} ->
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

  def group_by_row_key(rows) do
    initial = %{rows: [], row_key: ""}

    rows
    |> Enum.reduce(initial, &add_to_group/2)
    |> Map.fetch!(:rows)
    |> Enum.map(&Enum.reverse/1)
  end

  defp add_to_group(%{row_key: row_key} = chunk, accum) do
    %{rows: prev_rows, row_key: prev_row_key} = accum

    {head, _} = List.pop_at(prev_rows, 0, [])

    case new_row?(row_key, prev_row_key) do
      true ->
        next_rows = List.insert_at(prev_rows, 0, [chunk])

        %{rows: next_rows, row_key: row_key}

      false ->
        next_rows = List.replace_at(prev_rows, 0, [chunk | head])
        %{accum | rows: next_rows}
    end
  end

  defp new_row?(next_key, prev_key), do: next_key not in ["", prev_key]
end

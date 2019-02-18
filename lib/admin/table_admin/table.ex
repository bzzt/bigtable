defmodule Bigtable.Admin.Table do
  alias Google.Bigtable.Admin.V2

  def build(column_families) when is_map(column_families) do
    families =
      column_families
      |> Map.new(fn {name, gc_rule} ->
        {name, V2.ColumnFamily.new(gc_rule: gc_rule)}
      end)

    V2.Table.new(column_families: families)
  end
end

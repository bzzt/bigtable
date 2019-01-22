defmodule Bigtable.Typed.Get do
  def get_all(row_prefix) do
    regex = "^#{row_prefix}#\\w+"

    Bigtable.ReadRows.build()
    |> Bigtable.RowFilter.row_key_regex(regex)
    |> Bigtable.ReadRows.read()
  end

  def get_by_id(ids, row_prefix) do
    ids
    |> Enum.map(fn id -> "#{row_prefix}##{id}" end)
    |> Bigtable.RowSet.row_keys()
    |> Bigtable.ReadRows.read()
  end
end

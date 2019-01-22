defmodule Bigtable.Typed.Get do
  alias Bigtable.{ReadRows, RowFilter, RowSet}

  def get_all(row_prefix, update_patterns) do
  end

  def get_all(row_prefix) do
    regex = "^#{row_prefix}#\\w+"

    ReadRows.build()
    |> RowFilter.row_key_regex(regex)
    |> ReadRows.read()
  end

  def get_by_id(ids, row_prefix) do
    ids
    |> Enum.map(fn id -> "#{row_prefix}##{id}" end)
    |> RowSet.row_keys()
    |> ReadRows.read()
  end
end

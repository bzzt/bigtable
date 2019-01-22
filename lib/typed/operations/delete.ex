defmodule Bigtable.Typed.Delete do
  # TODO: Delete extra rowkey patterns
  alias Bigtable.{MutateRows, Mutations}

  def delete_all(row_prefix, update_patterns) do
  end

  def delete_by_id(ids, row_prefix) do
    mutations = Enum.map(ids, &delete_row(&1, row_prefix))

    mutations
    |> MutateRows.mutate()
  end

  defp delete_row(id, row_prefix) do
    entry = Mutations.build("#{row_prefix}##{id}")

    entry
    |> Mutations.delete_from_row()
  end
end

defmodule Bigtable.Typed.Delete do
  @moduledoc false
  alias Bigtable.{MutateRows, Mutations}

  # TODO: Delete extra rowkey patterns
  def delete_all do
    throw("Not implemented")
  end

  @spec delete_by_id([binary()], binary()) ::
          {:error, GRPC.RPCError.t()} | {:ok, Google.Bigtable.V2.MutateRowsResponse.t()}
  def delete_by_id(ids, row_prefix) do
    mutations = Enum.map(ids, &delete_row(&1, row_prefix))

    mutations
    |> MutateRows.mutate()
  end

  @spec delete_row(binary(), binary()) :: Google.Bigtable.V2.MutateRowsRequest.Entry.t()
  defp delete_row(id, row_prefix) do
    entry = Mutations.build("#{row_prefix}##{id}")

    entry
    |> Mutations.delete_from_row()
  end
end

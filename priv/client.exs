alias Google.Bigtable.V2
alias Bigtable.ReadRows

{:ok, channel} = GRPC.Stub.connect("localhost:8086", interceptors: [GRPC.Logger.Client])

# IO.inspect(channel)

{:ok, reply} =
  channel
  |> Bigtable.Stub.read_rows(
    V2.ReadRowsRequest.new(table_name: "projects/datahub-222411/instances/datahub/tables/ride")
  )

IO.inspect(reply)

alias Bigtable.ReadRows
alias ReadRows.{Request, RowSet, Filter}

Request.build()
|> RowSet.row_keys("ride#123")
|> Filter.cells_per_column(5)
|> ReadRows.read()

# {:ok, reply} =
#   channel
#   |> Bigtable.Stub.mutate_row(
#     V2.MutateRowRequest.new(
#       table_name: "projects/datahub-222411/instances/datahub/tables/ride",
#       row_key: <<"ride#123">>,
#       mutations: [
#         V2.Mutation.new(
#           mutation:
#             {:set_cell,
#              V2.Mutation.SetCell.new(
#                family_name: "ride",
#                column_qualifier: <<"baz">>,
#                timestamp_micros: -1,
#                value: <<123::little-signed-32>>
#              )}
#         )
#       ]
#     )
#   )

# IO.inspect(reply)

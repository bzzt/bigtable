alias Google.Bigtable.V2

{:ok, channel} = GRPC.Stub.connect("localhost:8086", interceptors: [GRPC.Logger.Client])

{:ok, reply} =
  channel
  |> Bigtable.Stub.read_rows(
    V2.ReadRowsRequest.new(table_name: "projects/datahub-222411/instances/datahub/tables/ride")
  )

IO.inspect(reply)

{:ok, reply} =
  channel
  |> Bigtable.Stub.mutate_row(
    V2.MutateRowRequest.new(
      table_name: "projects/datahub-222411/instances/datahub/tables/ride",
      row_key: <<"ride#123">>,
      mutations: [
        V2.Mutation.new(
          mutation:
            {:set_cell,
             V2.Mutation.SetCell.new(
               family_name: "ride",
               column_qualifier: <<"foo">>,
               timestamp_micros: -1,
               value: <<"bar">>
             )}
        )
      ]
    )
  )

IO.inspect(reply)

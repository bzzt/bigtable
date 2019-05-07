defmodule Bigtable.Service do
  @moduledoc false
  use GRPC.Service, name: "google.bigtable.v2.Bigtable"

  alias Google.Bigtable.V2

  rpc(:ReadRows, V2.ReadRowsRequest, stream(V2.ReadRowsResponse))
  rpc(:MutateRow, V2.MutateRowRequest, V2.MutateRowResponse)
  rpc(:MutateRows, V2.MutateRowsRequest, V2.MutateRowsResponse)
  rpc(:CheckAndMutateRow, V2.CheckAndMutateRowRequest, V2.CheckAndMutateRowResponse)
  rpc(:SampleRowKeys, V2.SampleRowKeysRequest, V2.SampleRowKeysResponse)
  rpc(:ReadModifyWriteRow, V2.ReadModifyWriteRowRequest, V2.ReadModifyWriteRowResponse)

  rpc(
    :ListTables,
    Google.Bigtable.Admin.V2.ListTablesRequest,
    stream(Google.Bigtable.Admin.V2.ListTablesResponse)
  )
end

defmodule Bigtable.Stub do
  @moduledoc false
  use GRPC.Stub, service: Bigtable.Service
end

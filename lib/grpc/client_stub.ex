defmodule Bigtable.Service do
  @moduledoc false
  use GRPC.Service, name: "google.bigtable.v2.Bigtable"

  alias Google.Bigtable.V2

  rpc(:ReadRows, V2.ReadRowsRequest, stream(V2.ReadRowsResponse))
  rpc(:MutateRow, V2.MutateRowRequest, stream(V2.MutateRowResponse))
  rpc(:MutateRows, V2.MutateRowsRequest, stream(V2.MutateRowsResponse))
end

defmodule Bigtable.Stub do
  @moduledoc false
  use GRPC.Stub, service: Bigtable.Service
end

defmodule Bigtable.Service do
  @moduledoc """
  Creates a gRPC service which points at the Google Bigtable V2 service
  """
  use GRPC.Service, name: "google.bigtable.v2.Bigtable"

  alias Google.Bigtable.V2

  rpc(:ReadRows, V2.ReadRowsRequest, stream(V2.ReadRowsResponse))
  rpc(:MutateRow, V2.MutateRowRequest, V2.MutateRowResponse)
  rpc(:MutateRows, V2.MutateRowsRequest, V2.MutateRowsResponse)
end

defmodule Bigtable.Stub do
  @moduledoc """
  Creates a gRPC client stub for use with the Bigtable service
  """
  use GRPC.Stub, service: Bigtable.Service
end

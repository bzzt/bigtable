# defmodule Bigtable.ReadRowsRequest do
#   use Protobuf

#   defstruct [:table_name, :app_profile_id, :rows, :filter, :rows_limit]

#   field(:table_name, 1, optional: false, type: :string)
#   field(:app_profile_id, 2, optional: true, type: :string)
# end

# defmodule Bigtable.ReadRowsResponse do
#   use Protobuf

#   defstruct [:last_scanned_row_key]

#   field(:last_scanned_row_key, 2, optional: true, type: :bytes)
# end

defmodule Bigtable.Service do
  use GRPC.Service, name: "google.bigtable.v2.Bigtable"

  alias Google.Bigtable.V2

  rpc(:ReadRows, V2.ReadRowsRequest, V2.ReadRowsResponse)
  rpc(:MutateRow, V2.MutateRowRequest, V2.MutateRowResponse)
  rpc(:MutateRows, V2.MutateRowsRequest, V2.MutateRowsResponse)
end

defmodule Bigtable.Stub do
  use GRPC.Stub, service: Bigtable.Service
end

defmodule Google.Bigtable.Admin.V2.CreateTableRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          parent: String.t(),
          table_id: String.t(),
          table: Google.Bigtable.Admin.V2.Table.t(),
          initial_splits: [Google.Bigtable.Admin.V2.CreateTableRequest.Split.t()]
        }
  defstruct [:parent, :table_id, :table, :initial_splits]

  field :parent, 1, type: :string
  field :table_id, 2, type: :string
  field :table, 3, type: Google.Bigtable.Admin.V2.Table

  field :initial_splits, 4,
    repeated: true,
    type: Google.Bigtable.Admin.V2.CreateTableRequest.Split
end

defmodule Google.Bigtable.Admin.V2.CreateTableRequest.Split do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t()
        }
  defstruct [:key]

  field :key, 1, type: :bytes
end

defmodule Google.Bigtable.Admin.V2.CreateTableFromSnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          parent: String.t(),
          table_id: String.t(),
          source_snapshot: String.t()
        }
  defstruct [:parent, :table_id, :source_snapshot]

  field :parent, 1, type: :string
  field :table_id, 2, type: :string
  field :source_snapshot, 3, type: :string
end

defmodule Google.Bigtable.Admin.V2.DropRowRangeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          target: {atom, any},
          name: String.t()
        }
  defstruct [:target, :name]

  oneof :target, 0
  field :name, 1, type: :string
  field :row_key_prefix, 2, type: :bytes, oneof: 0
  field :delete_all_data_from_table, 3, type: :bool, oneof: 0
end

defmodule Google.Bigtable.Admin.V2.ListTablesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          parent: String.t(),
          view: integer,
          page_size: integer,
          page_token: String.t()
        }
  defstruct [:parent, :view, :page_size, :page_token]

  field :parent, 1, type: :string
  field :view, 2, type: Google.Bigtable.Admin.V2.Table.View, enum: true
  field :page_size, 4, type: :int32
  field :page_token, 3, type: :string
end

defmodule Google.Bigtable.Admin.V2.ListTablesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          tables: [Google.Bigtable.Admin.V2.Table.t()],
          next_page_token: String.t()
        }
  defstruct [:tables, :next_page_token]

  field :tables, 1, repeated: true, type: Google.Bigtable.Admin.V2.Table
  field :next_page_token, 2, type: :string
end

defmodule Google.Bigtable.Admin.V2.GetTableRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          view: integer
        }
  defstruct [:name, :view]

  field :name, 1, type: :string
  field :view, 2, type: Google.Bigtable.Admin.V2.Table.View, enum: true
end

defmodule Google.Bigtable.Admin.V2.DeleteTableRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Google.Bigtable.Admin.V2.ModifyColumnFamiliesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          modifications: [Google.Bigtable.Admin.V2.ModifyColumnFamiliesRequest.Modification.t()]
        }
  defstruct [:name, :modifications]

  field :name, 1, type: :string

  field :modifications, 2,
    repeated: true,
    type: Google.Bigtable.Admin.V2.ModifyColumnFamiliesRequest.Modification
end

defmodule Google.Bigtable.Admin.V2.ModifyColumnFamiliesRequest.Modification do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          mod: {atom, any},
          id: String.t()
        }
  defstruct [:mod, :id]

  oneof :mod, 0
  field :id, 1, type: :string
  field :create, 2, type: Google.Bigtable.Admin.V2.ColumnFamily, oneof: 0
  field :update, 3, type: Google.Bigtable.Admin.V2.ColumnFamily, oneof: 0
  field :drop, 4, type: :bool, oneof: 0
end

defmodule Google.Bigtable.Admin.V2.GenerateConsistencyTokenRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Google.Bigtable.Admin.V2.GenerateConsistencyTokenResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          consistency_token: String.t()
        }
  defstruct [:consistency_token]

  field :consistency_token, 1, type: :string
end

defmodule Google.Bigtable.Admin.V2.CheckConsistencyRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          consistency_token: String.t()
        }
  defstruct [:name, :consistency_token]

  field :name, 1, type: :string
  field :consistency_token, 2, type: :string
end

defmodule Google.Bigtable.Admin.V2.CheckConsistencyResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          consistent: boolean
        }
  defstruct [:consistent]

  field :consistent, 1, type: :bool
end

defmodule Google.Bigtable.Admin.V2.SnapshotTableRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          cluster: String.t(),
          snapshot_id: String.t(),
          ttl: Google.Protobuf.Duration.t(),
          description: String.t()
        }
  defstruct [:name, :cluster, :snapshot_id, :ttl, :description]

  field :name, 1, type: :string
  field :cluster, 2, type: :string
  field :snapshot_id, 3, type: :string
  field :ttl, 4, type: Google.Protobuf.Duration
  field :description, 5, type: :string
end

defmodule Google.Bigtable.Admin.V2.GetSnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Google.Bigtable.Admin.V2.ListSnapshotsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          parent: String.t(),
          page_size: integer,
          page_token: String.t()
        }
  defstruct [:parent, :page_size, :page_token]

  field :parent, 1, type: :string
  field :page_size, 2, type: :int32
  field :page_token, 3, type: :string
end

defmodule Google.Bigtable.Admin.V2.ListSnapshotsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          snapshots: [Google.Bigtable.Admin.V2.Snapshot.t()],
          next_page_token: String.t()
        }
  defstruct [:snapshots, :next_page_token]

  field :snapshots, 1, repeated: true, type: Google.Bigtable.Admin.V2.Snapshot
  field :next_page_token, 2, type: :string
end

defmodule Google.Bigtable.Admin.V2.DeleteSnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t()
        }
  defstruct [:name]

  field :name, 1, type: :string
end

defmodule Google.Bigtable.Admin.V2.SnapshotTableMetadata do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          original_request: Google.Bigtable.Admin.V2.SnapshotTableRequest.t(),
          request_time: Google.Protobuf.Timestamp.t(),
          finish_time: Google.Protobuf.Timestamp.t()
        }
  defstruct [:original_request, :request_time, :finish_time]

  field :original_request, 1, type: Google.Bigtable.Admin.V2.SnapshotTableRequest
  field :request_time, 2, type: Google.Protobuf.Timestamp
  field :finish_time, 3, type: Google.Protobuf.Timestamp
end

defmodule Google.Bigtable.Admin.V2.CreateTableFromSnapshotMetadata do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          original_request: Google.Bigtable.Admin.V2.CreateTableFromSnapshotRequest.t(),
          request_time: Google.Protobuf.Timestamp.t(),
          finish_time: Google.Protobuf.Timestamp.t()
        }
  defstruct [:original_request, :request_time, :finish_time]

  field :original_request, 1, type: Google.Bigtable.Admin.V2.CreateTableFromSnapshotRequest
  field :request_time, 2, type: Google.Protobuf.Timestamp
  field :finish_time, 3, type: Google.Protobuf.Timestamp
end

defmodule Google.Bigtable.Admin.V2.BigtableTableAdmin.Service do
  @moduledoc false
  use GRPC.Service, name: "google.bigtable.admin.v2.BigtableTableAdmin"

  rpc :CreateTable, Google.Bigtable.Admin.V2.CreateTableRequest, Google.Bigtable.Admin.V2.Table

  rpc :CreateTableFromSnapshot,
      Google.Bigtable.Admin.V2.CreateTableFromSnapshotRequest,
      Google.Longrunning.Operation

  rpc :ListTables,
      Google.Bigtable.Admin.V2.ListTablesRequest,
      Google.Bigtable.Admin.V2.ListTablesResponse

  rpc :GetTable, Google.Bigtable.Admin.V2.GetTableRequest, Google.Bigtable.Admin.V2.Table
  rpc :DeleteTable, Google.Bigtable.Admin.V2.DeleteTableRequest, Google.Protobuf.Empty

  rpc :ModifyColumnFamilies,
      Google.Bigtable.Admin.V2.ModifyColumnFamiliesRequest,
      Google.Bigtable.Admin.V2.Table

  rpc :DropRowRange, Google.Bigtable.Admin.V2.DropRowRangeRequest, Google.Protobuf.Empty

  rpc :GenerateConsistencyToken,
      Google.Bigtable.Admin.V2.GenerateConsistencyTokenRequest,
      Google.Bigtable.Admin.V2.GenerateConsistencyTokenResponse

  rpc :CheckConsistency,
      Google.Bigtable.Admin.V2.CheckConsistencyRequest,
      Google.Bigtable.Admin.V2.CheckConsistencyResponse

  rpc :SnapshotTable, Google.Bigtable.Admin.V2.SnapshotTableRequest, Google.Longrunning.Operation
  rpc :GetSnapshot, Google.Bigtable.Admin.V2.GetSnapshotRequest, Google.Bigtable.Admin.V2.Snapshot

  rpc :ListSnapshots,
      Google.Bigtable.Admin.V2.ListSnapshotsRequest,
      Google.Bigtable.Admin.V2.ListSnapshotsResponse

  rpc :DeleteSnapshot, Google.Bigtable.Admin.V2.DeleteSnapshotRequest, Google.Protobuf.Empty
end

defmodule Google.Bigtable.Admin.V2.BigtableTableAdmin.Stub do
  @moduledoc false
  use GRPC.Stub, service: Google.Bigtable.Admin.V2.BigtableTableAdmin.Service
end

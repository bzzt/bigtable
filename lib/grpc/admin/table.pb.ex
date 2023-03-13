defmodule Google.Bigtable.Admin.V2.Table do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          cluster_states: %{String.t() => Google.Bigtable.Admin.V2.Table.ClusterState.t()},
          column_families: %{String.t() => Google.Bigtable.Admin.V2.ColumnFamily.t()},
          granularity: integer
        }
  defstruct [:name, :cluster_states, :column_families, :granularity]

  field(:name, 1, type: :string)

  field(:cluster_states, 2,
    repeated: true,
    type: Google.Bigtable.Admin.V2.Table.ClusterStatesEntry,
    map: true
  )

  field(:column_families, 3,
    repeated: true,
    type: Google.Bigtable.Admin.V2.Table.ColumnFamiliesEntry,
    map: true
  )

  field(:granularity, 4, type: Google.Bigtable.Admin.V2.Table.TimestampGranularity, enum: true)
end

defmodule Google.Bigtable.Admin.V2.Table.ClusterState do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          replication_state: integer
        }
  defstruct [:replication_state]

  field(:replication_state, 1,
    type: Google.Bigtable.Admin.V2.Table.ClusterState.ReplicationState,
    enum: true
  )
end

defmodule Google.Bigtable.Admin.V2.Table.ClusterState.ReplicationState do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field(:STATE_NOT_KNOWN, 0)
  field(:INITIALIZING, 1)
  field(:PLANNED_MAINTENANCE, 2)
  field(:UNPLANNED_MAINTENANCE, 3)
  field(:READY, 4)
end

defmodule Google.Bigtable.Admin.V2.Table.ClusterStatesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: Google.Bigtable.Admin.V2.Table.ClusterState.t()
        }
  defstruct [:key, :value]

  field(:key, 1, type: :string)
  field(:value, 2, type: Google.Bigtable.Admin.V2.Table.ClusterState)
end

defmodule Google.Bigtable.Admin.V2.Table.ColumnFamiliesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: Google.Bigtable.Admin.V2.ColumnFamily.t()
        }
  defstruct [:key, :value]

  field(:key, 1, type: :string)
  field(:value, 2, type: Google.Bigtable.Admin.V2.ColumnFamily)
end

defmodule Google.Bigtable.Admin.V2.Table.TimestampGranularity do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field(:TIMESTAMP_GRANULARITY_UNSPECIFIED, 0)
  field(:MILLIS, 1)
end

defmodule Google.Bigtable.Admin.V2.Table.View do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field(:VIEW_UNSPECIFIED, 0)
  field(:NAME_ONLY, 1)
  field(:SCHEMA_VIEW, 2)
  field(:REPLICATION_VIEW, 3)
  field(:FULL, 4)
end

defmodule Google.Bigtable.Admin.V2.ColumnFamily do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          gc_rule: Google.Bigtable.Admin.V2.GcRule.t()
        }
  defstruct [:gc_rule]

  field(:gc_rule, 1, type: Google.Bigtable.Admin.V2.GcRule)
end

defmodule Google.Bigtable.Admin.V2.GcRule do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rule: {atom, any}
        }
  defstruct [:rule]

  oneof(:rule, 0)
  field(:max_num_versions, 1, type: :int32, oneof: 0)
  field(:max_age, 2, type: Google.Protobuf.Duration, oneof: 0)
  field(:intersection, 3, type: Google.Bigtable.Admin.V2.GcRule.Intersection, oneof: 0)
  field(:union, 4, type: Google.Bigtable.Admin.V2.GcRule.Union, oneof: 0)
end

defmodule Google.Bigtable.Admin.V2.GcRule.Intersection do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rules: [Google.Bigtable.Admin.V2.GcRule.t()]
        }
  defstruct [:rules]

  field(:rules, 1, repeated: true, type: Google.Bigtable.Admin.V2.GcRule)
end

defmodule Google.Bigtable.Admin.V2.GcRule.Union do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rules: [Google.Bigtable.Admin.V2.GcRule.t()]
        }
  defstruct [:rules]

  field(:rules, 1, repeated: true, type: Google.Bigtable.Admin.V2.GcRule)
end

defmodule Google.Bigtable.Admin.V2.Snapshot do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          source_table: Google.Bigtable.Admin.V2.Table.t(),
          data_size_bytes: integer,
          create_time: Google.Protobuf.Timestamp.t(),
          delete_time: Google.Protobuf.Timestamp.t(),
          state: integer,
          description: String.t()
        }
  defstruct [
    :name,
    :source_table,
    :data_size_bytes,
    :create_time,
    :delete_time,
    :state,
    :description
  ]

  field(:name, 1, type: :string)
  field(:source_table, 2, type: Google.Bigtable.Admin.V2.Table)
  field(:data_size_bytes, 3, type: :int64)
  field(:create_time, 4, type: Google.Protobuf.Timestamp)
  field(:delete_time, 5, type: Google.Protobuf.Timestamp)
  field(:state, 6, type: Google.Bigtable.Admin.V2.Snapshot.State, enum: true)
  field(:description, 7, type: :string)
end

defmodule Google.Bigtable.Admin.V2.Snapshot.State do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  field(:STATE_NOT_KNOWN, 0)
  field(:READY, 1)
  field(:CREATING, 2)
end

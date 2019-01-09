defmodule Google.Bigtable.V2.ReadRowsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          table_name: String.t(),
          app_profile_id: String.t(),
          rows: Google.Bigtable.V2.RowSet.t(),
          filter: Google.Bigtable.V2.RowFilter.t(),
          rows_limit: integer
        }
  defstruct [:table_name, :app_profile_id, :rows, :filter, :rows_limit]

  field :table_name, 1, type: :string
  field :app_profile_id, 5, type: :string
  field :rows, 2, type: Google.Bigtable.V2.RowSet
  field :filter, 3, type: Google.Bigtable.V2.RowFilter
  field :rows_limit, 4, type: :int64
end

defmodule Google.Bigtable.V2.ReadRowsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          chunks: [Google.Bigtable.V2.ReadRowsResponse.CellChunk.t()],
          last_scanned_row_key: String.t()
        }
  defstruct [:chunks, :last_scanned_row_key]

  field :chunks, 1, repeated: true, type: Google.Bigtable.V2.ReadRowsResponse.CellChunk
  field :last_scanned_row_key, 2, type: :bytes
end

defmodule Google.Bigtable.V2.ReadRowsResponse.CellChunk do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          row_status: {atom, any},
          row_key: String.t(),
          family_name: Google.Protobuf.StringValue.t(),
          qualifier: Google.Protobuf.BytesValue.t(),
          timestamp_micros: integer,
          labels: [String.t()],
          value: String.t(),
          value_size: integer
        }
  defstruct [
    :row_status,
    :row_key,
    :family_name,
    :qualifier,
    :timestamp_micros,
    :labels,
    :value,
    :value_size
  ]

  oneof :row_status, 0
  field :row_key, 1, type: :bytes
  field :family_name, 2, type: Google.Protobuf.StringValue
  field :qualifier, 3, type: Google.Protobuf.BytesValue
  field :timestamp_micros, 4, type: :int64
  field :labels, 5, repeated: true, type: :string
  field :value, 6, type: :bytes
  field :value_size, 7, type: :int32
  field :reset_row, 8, type: :bool, oneof: 0
  field :commit_row, 9, type: :bool, oneof: 0
end

defmodule Google.Bigtable.V2.SampleRowKeysRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          table_name: String.t(),
          app_profile_id: String.t()
        }
  defstruct [:table_name, :app_profile_id]

  field :table_name, 1, type: :string
  field :app_profile_id, 2, type: :string
end

defmodule Google.Bigtable.V2.SampleRowKeysResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          row_key: String.t(),
          offset_bytes: integer
        }
  defstruct [:row_key, :offset_bytes]

  field :row_key, 1, type: :bytes
  field :offset_bytes, 2, type: :int64
end

defmodule Google.Bigtable.V2.MutateRowRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          table_name: String.t(),
          app_profile_id: String.t(),
          row_key: String.t(),
          mutations: [Google.Bigtable.V2.Mutation.t()]
        }
  defstruct [:table_name, :app_profile_id, :row_key, :mutations]

  field :table_name, 1, type: :string
  field :app_profile_id, 4, type: :string
  field :row_key, 2, type: :bytes
  field :mutations, 3, repeated: true, type: Google.Bigtable.V2.Mutation
end

defmodule Google.Bigtable.V2.MutateRowResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  defstruct []
end

defmodule Google.Bigtable.V2.MutateRowsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          table_name: String.t(),
          app_profile_id: String.t(),
          entries: [Google.Bigtable.V2.MutateRowsRequest.Entry.t()]
        }
  defstruct [:table_name, :app_profile_id, :entries]

  field :table_name, 1, type: :string
  field :app_profile_id, 3, type: :string
  field :entries, 2, repeated: true, type: Google.Bigtable.V2.MutateRowsRequest.Entry
end

defmodule Google.Bigtable.V2.MutateRowsRequest.Entry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          row_key: String.t(),
          mutations: [Google.Bigtable.V2.Mutation.t()]
        }
  defstruct [:row_key, :mutations]

  field :row_key, 1, type: :bytes
  field :mutations, 2, repeated: true, type: Google.Bigtable.V2.Mutation
end

defmodule Google.Bigtable.V2.MutateRowsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          entries: [Google.Bigtable.V2.MutateRowsResponse.Entry.t()]
        }
  defstruct [:entries]

  field :entries, 1, repeated: true, type: Google.Bigtable.V2.MutateRowsResponse.Entry
end

defmodule Google.Bigtable.V2.MutateRowsResponse.Entry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          index: integer,
          status: Google.Rpc.Status.t()
        }
  defstruct [:index, :status]

  field :index, 1, type: :int64
  field :status, 2, type: Google.Rpc.Status
end

defmodule Google.Bigtable.V2.CheckAndMutateRowRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          table_name: String.t(),
          app_profile_id: String.t(),
          row_key: String.t(),
          predicate_filter: Google.Bigtable.V2.RowFilter.t(),
          true_mutations: [Google.Bigtable.V2.Mutation.t()],
          false_mutations: [Google.Bigtable.V2.Mutation.t()]
        }
  defstruct [
    :table_name,
    :app_profile_id,
    :row_key,
    :predicate_filter,
    :true_mutations,
    :false_mutations
  ]

  field :table_name, 1, type: :string
  field :app_profile_id, 7, type: :string
  field :row_key, 2, type: :bytes
  field :predicate_filter, 6, type: Google.Bigtable.V2.RowFilter
  field :true_mutations, 4, repeated: true, type: Google.Bigtable.V2.Mutation
  field :false_mutations, 5, repeated: true, type: Google.Bigtable.V2.Mutation
end

defmodule Google.Bigtable.V2.CheckAndMutateRowResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          predicate_matched: boolean
        }
  defstruct [:predicate_matched]

  field :predicate_matched, 1, type: :bool
end

defmodule Google.Bigtable.V2.ReadModifyWriteRowRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          table_name: String.t(),
          app_profile_id: String.t(),
          row_key: String.t(),
          rules: [Google.Bigtable.V2.ReadModifyWriteRule.t()]
        }
  defstruct [:table_name, :app_profile_id, :row_key, :rules]

  field :table_name, 1, type: :string
  field :app_profile_id, 4, type: :string
  field :row_key, 2, type: :bytes
  field :rules, 3, repeated: true, type: Google.Bigtable.V2.ReadModifyWriteRule
end

defmodule Google.Bigtable.V2.ReadModifyWriteRowResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          row: Google.Bigtable.V2.Row.t()
        }
  defstruct [:row]

  field :row, 1, type: Google.Bigtable.V2.Row
end

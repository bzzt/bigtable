defmodule Google.Bigtable.V2.Row do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          families: [Google.Bigtable.V2.Family.t()]
        }
  defstruct [:key, :families]

  field(:key, 1, type: :bytes)
  field(:families, 2, repeated: true, type: Google.Bigtable.V2.Family)
end

defmodule Google.Bigtable.V2.Family do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          columns: [Google.Bigtable.V2.Column.t()]
        }
  defstruct [:name, :columns]

  field(:name, 1, type: :string)
  field(:columns, 2, repeated: true, type: Google.Bigtable.V2.Column)
end

defmodule Google.Bigtable.V2.Column do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          qualifier: String.t(),
          cells: [Google.Bigtable.V2.Cell.t()]
        }
  defstruct [:qualifier, :cells]

  field(:qualifier, 1, type: :bytes)
  field(:cells, 2, repeated: true, type: Google.Bigtable.V2.Cell)
end

defmodule Google.Bigtable.V2.Cell do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          timestamp_micros: integer,
          value: String.t(),
          labels: [String.t()]
        }
  defstruct [:timestamp_micros, :value, :labels]

  field(:timestamp_micros, 1, type: :int64)
  field(:value, 2, type: :bytes)
  field(:labels, 3, repeated: true, type: :string)
end

defmodule Google.Bigtable.V2.RowRange do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          start_key: {atom, any},
          end_key: {atom, any}
        }
  defstruct [:start_key, :end_key]

  oneof(:start_key, 0)
  oneof(:end_key, 1)
  field(:start_key_closed, 1, type: :bytes, oneof: 0)
  field(:start_key_open, 2, type: :bytes, oneof: 0)
  field(:end_key_open, 3, type: :bytes, oneof: 1)
  field(:end_key_closed, 4, type: :bytes, oneof: 1)
end

defmodule Google.Bigtable.V2.RowSet do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          row_keys: [String.t()],
          row_ranges: [Google.Bigtable.V2.RowRange.t()]
        }
  defstruct [:row_keys, :row_ranges]

  field(:row_keys, 1, repeated: true, type: :bytes)
  field(:row_ranges, 2, repeated: true, type: Google.Bigtable.V2.RowRange)
end

defmodule Google.Bigtable.V2.ColumnRange do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          start_qualifier: {atom, any},
          end_qualifier: {atom, any},
          family_name: String.t()
        }
  defstruct [:start_qualifier, :end_qualifier, :family_name]

  oneof(:start_qualifier, 0)
  oneof(:end_qualifier, 1)
  field(:family_name, 1, type: :string)
  field(:start_qualifier_closed, 2, type: :bytes, oneof: 0)
  field(:start_qualifier_open, 3, type: :bytes, oneof: 0)
  field(:end_qualifier_closed, 4, type: :bytes, oneof: 1)
  field(:end_qualifier_open, 5, type: :bytes, oneof: 1)
end

defmodule Google.Bigtable.V2.TimestampRange do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          start_timestamp_micros: integer,
          end_timestamp_micros: integer
        }
  defstruct [:start_timestamp_micros, :end_timestamp_micros]

  field(:start_timestamp_micros, 1, type: :int64)
  field(:end_timestamp_micros, 2, type: :int64)
end

defmodule Google.Bigtable.V2.ValueRange do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          start_value: {atom, any},
          end_value: {atom, any}
        }
  defstruct [:start_value, :end_value]

  oneof(:start_value, 0)
  oneof(:end_value, 1)
  field(:start_value_closed, 1, type: :bytes, oneof: 0)
  field(:start_value_open, 2, type: :bytes, oneof: 0)
  field(:end_value_closed, 3, type: :bytes, oneof: 1)
  field(:end_value_open, 4, type: :bytes, oneof: 1)
end

defmodule Google.Bigtable.V2.RowFilter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          filter: {atom, any}
        }
  defstruct [:filter]

  oneof(:filter, 0)
  field(:chain, 1, type: Google.Bigtable.V2.RowFilter.Chain, oneof: 0)
  field(:interleave, 2, type: Google.Bigtable.V2.RowFilter.Interleave, oneof: 0)
  field(:condition, 3, type: Google.Bigtable.V2.RowFilter.Condition, oneof: 0)
  field(:sink, 16, type: :bool, oneof: 0)
  field(:pass_all_filter, 17, type: :bool, oneof: 0)
  field(:block_all_filter, 18, type: :bool, oneof: 0)
  field(:row_key_regex_filter, 4, type: :bytes, oneof: 0)
  field(:row_sample_filter, 14, type: :double, oneof: 0)
  field(:family_name_regex_filter, 5, type: :string, oneof: 0)
  field(:column_qualifier_regex_filter, 6, type: :bytes, oneof: 0)
  field(:column_range_filter, 7, type: Google.Bigtable.V2.ColumnRange, oneof: 0)
  field(:timestamp_range_filter, 8, type: Google.Bigtable.V2.TimestampRange, oneof: 0)
  field(:value_regex_filter, 9, type: :bytes, oneof: 0)
  field(:value_range_filter, 15, type: Google.Bigtable.V2.ValueRange, oneof: 0)
  field(:cells_per_row_offset_filter, 10, type: :int32, oneof: 0)
  field(:cells_per_row_limit_filter, 11, type: :int32, oneof: 0)
  field(:cells_per_column_limit_filter, 12, type: :int32, oneof: 0)
  field(:strip_value_transformer, 13, type: :bool, oneof: 0)
  field(:apply_label_transformer, 19, type: :string, oneof: 0)
end

defmodule Google.Bigtable.V2.RowFilter.Chain do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          filters: [Google.Bigtable.V2.RowFilter.t()]
        }
  defstruct [:filters]

  field(:filters, 1, repeated: true, type: Google.Bigtable.V2.RowFilter)
end

defmodule Google.Bigtable.V2.RowFilter.Interleave do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          filters: [Google.Bigtable.V2.RowFilter.t()]
        }
  defstruct [:filters]

  field(:filters, 1, repeated: true, type: Google.Bigtable.V2.RowFilter)
end

defmodule Google.Bigtable.V2.RowFilter.Condition do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          predicate_filter: Google.Bigtable.V2.RowFilter.t(),
          true_filter: Google.Bigtable.V2.RowFilter.t(),
          false_filter: Google.Bigtable.V2.RowFilter.t()
        }
  defstruct [:predicate_filter, :true_filter, :false_filter]

  field(:predicate_filter, 1, type: Google.Bigtable.V2.RowFilter)
  field(:true_filter, 2, type: Google.Bigtable.V2.RowFilter)
  field(:false_filter, 3, type: Google.Bigtable.V2.RowFilter)
end

defmodule Google.Bigtable.V2.Mutation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          mutation: {atom, any}
        }
  defstruct [:mutation]

  oneof(:mutation, 0)
  field(:set_cell, 1, type: Google.Bigtable.V2.Mutation.SetCell, oneof: 0)
  field(:delete_from_column, 2, type: Google.Bigtable.V2.Mutation.DeleteFromColumn, oneof: 0)
  field(:delete_from_family, 3, type: Google.Bigtable.V2.Mutation.DeleteFromFamily, oneof: 0)
  field(:delete_from_row, 4, type: Google.Bigtable.V2.Mutation.DeleteFromRow, oneof: 0)
end

defmodule Google.Bigtable.V2.Mutation.SetCell do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          family_name: String.t(),
          column_qualifier: String.t(),
          timestamp_micros: integer,
          value: String.t()
        }
  defstruct [:family_name, :column_qualifier, :timestamp_micros, :value]

  field(:family_name, 1, type: :string)
  field(:column_qualifier, 2, type: :bytes)
  field(:timestamp_micros, 3, type: :int64)
  field(:value, 4, type: :bytes)
end

defmodule Google.Bigtable.V2.Mutation.DeleteFromColumn do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          family_name: String.t(),
          column_qualifier: String.t(),
          time_range: Google.Bigtable.V2.TimestampRange.t()
        }
  defstruct [:family_name, :column_qualifier, :time_range]

  field(:family_name, 1, type: :string)
  field(:column_qualifier, 2, type: :bytes)
  field(:time_range, 3, type: Google.Bigtable.V2.TimestampRange)
end

defmodule Google.Bigtable.V2.Mutation.DeleteFromFamily do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          family_name: String.t()
        }
  defstruct [:family_name]

  field(:family_name, 1, type: :string)
end

defmodule Google.Bigtable.V2.Mutation.DeleteFromRow do
  @moduledoc false
  use Protobuf, syntax: :proto3

  defstruct []
end

defmodule Google.Bigtable.V2.ReadModifyWriteRule do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rule: {atom, any},
          family_name: String.t(),
          column_qualifier: String.t()
        }
  defstruct [:rule, :family_name, :column_qualifier]

  oneof(:rule, 0)
  field(:family_name, 1, type: :string)
  field(:column_qualifier, 2, type: :bytes)
  field(:append_value, 3, type: :bytes, oneof: 0)
  field(:increment_amount, 4, type: :int64, oneof: 0)
end

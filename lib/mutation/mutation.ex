defmodule Bigtable.Mutation do
  alias Google.Bigtable.V2

  defstruct row_key: nil, mutations: []

  @doc """
  Builds a Mutation Struct for use with MutateRowRequest and MutateRowsRequest
  """
  def build(row_key) when is_binary(row_key) do
    %__MODULE__{
      row_key: row_key
    }
  end

  @doc """
  Creates a SetCell V2.Mutation given a Mutation, family name, column qualifier, and timestamp micros.

  The timestamp of the cell into which new data should be written.
  Use -1 for current Bigtable server time. Otherwise, the client should set this value itself, noting that the default value is a timestamp of zero if the field is left unspecified.
  Values must match the granularity of the table (e.g. micros, millis)
  """
  def set_cell(%__MODULE__{} = mutation, family, column, value, timestamp \\ -1)
      when is_binary(family) and is_binary(column) and is_binary(value) and is_integer(timestamp) do
    set_mutation =
      V2.Mutation.SetCell.new(
        family_name: family,
        column_qualifier: column,
        value: value,
        timestamp_micros: timestamp
      )

    add_mutation(mutation, :set_cell, set_mutation)
  end

  @doc """
  Creates a DeleteFromColumn V2.Mutation given a Mutation, family name, column qualifier, and time range.
  Time range is a keyword list that should contain optional start_timestamp_micros and end_timestamp_micros.
  If not provided, start is treated as 0 and end is treated as infinity
  """
  def delete_from_column(%__MODULE__{} = mutation_struct, family, column, time_range \\ [])
      when is_binary(family) and is_binary(column) do
    time_range = create_time_range(time_range)

    mutation =
      V2.Mutation.DeleteFromColumn.new(
        family_name: family,
        column_qualifier: column,
        time_range: time_range
      )

    add_mutation(mutation_struct, :delete_from_column, mutation)
  end

  @doc """
  Deletes all cells from the specified column family
  """
  def delete_from_family(%__MODULE__{} = mutation_struct, family) when is_binary(family) do
    mutation = V2.Mutation.DeleteFromFamily.new(family_name: family)

    add_mutation(mutation_struct, :delete_from_family, mutation)
  end

  @doc """
  Deletes all columns from the given row
  """
  def delete_from_row(%__MODULE__{} = mutation_struct) do
    mutation = V2.Mutation.DeleteFromRow.new()

    add_mutation(mutation_struct, :delete_from_row, mutation)
  end

  # Adds an additional V2.Mutation to the given mutation struct
  defp add_mutation(%__MODULE__{} = mutation_struct, type, mutation) do
    %{
      mutation_struct
      | mutations: mutation_struct.mutations ++ [V2.Mutation.new(mutation: {type, mutation})]
    }
  end

  # Creates a time range that can be used for column deletes
  defp create_time_range(time_range) do
    start_timestamp_micros = Keyword.get(time_range, :start)
    end_timestamp_micros = Keyword.get(time_range, :end)

    time_range = V2.TimestampRange.new()

    time_range =
      case start_timestamp_micros do
        nil -> time_range
        micros -> %{time_range | start_timestamp_micros: micros}
      end

    time_range =
      case end_timestamp_micros do
        nil -> time_range
        micros -> %{time_range | end_timestamp_micros: micros}
      end

    time_range
  end
end

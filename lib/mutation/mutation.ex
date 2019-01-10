defmodule Bigtable.Mutation do
  alias Google.Bigtable.V2

  defstruct row_key: nil, mutations: []

  def build(row_key) when is_binary(row_key) do
    %__MODULE__{
      row_key: row_key
    }
  end

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

  def delete_from_column(%__MODULE__{} = mutation, family, column, time_range \\ []) do
    time_range = create_timerange(time_range)

    delete_mutation =
      V2.Mutation.DeleteFromColumn.new(
        family_name: family,
        column_qualifier: column,
        time_range: time_range
      )

    add_mutation(mutation, :delete_from_column, delete_mutation)
  end

  def delete_from_family(%__MODULE__{} = mutation) do
  end

  def delete_from_row(%__MODULE__{} = mutation) do
  end

  defp add_mutation(%__MODULE__{} = mutation, type, to_add) do
    %{mutation | mutations: mutation.mutations ++ [V2.Mutation.new(mutation: {type, to_add})]}
  end

  defp create_timerange(time_range) do
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

defmodule Bigtable.Data.Mutations do
  @moduledoc """
  Provides functions to build Bigtable mutations that are used when forming
  row mutation requests.
  """
  alias Google.Bigtable.V2.{MutateRowsRequest, Mutation, TimestampRange}
  alias MutateRowsRequest.Entry
  alias Mutation.{DeleteFromColumn, DeleteFromFamily, DeleteFromRow, SetCell}

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowsRequest.Entry` for use with `Google.Bigtable.V2.MutateRowRequest` and `Google.Bigtable.V2.MutateRowsRequest`.

  ## Examples

      iex> Bigtable.Data.Mutations.build("Row#123")
      %Google.Bigtable.V2.MutateRowsRequest.Entry{mutations: [], row_key: "Row#123"}
  """
  @spec build(binary()) :: Entry.t()
  def build(row_key) when is_binary(row_key) do
    Entry.new(row_key: row_key)
  end

  @doc """
  Creates a `Google.Bigtable.V2.Mutation.SetCell` given a `Google.Bigtable.V2.Mutation`, family name, column qualifier, and timestamp micros.

  The provided timestamp corresponds to the timestamp of the cell into which new data should be written.
  Use -1 for current Bigtable server time. Otherwise, the client should set this value itself, noting that the default value is a timestamp of zero if the field is left unspecified.
  Values must match the granularity of the table (e.g. micros, millis)

  ## Examples

      iex> Mutations.build("Row#123") |> Mutations.set_cell("family", "column", "value")
      %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation: {:set_cell,
            %Google.Bigtable.V2.Mutation.SetCell{
              column_qualifier: "column",
              family_name: "family",
              timestamp_micros: -1,
              value: "value"
            }}
          }
        ],
        row_key: "Row#123"
      }
  """
  @spec set_cell(Entry.t(), binary(), binary(), binary(), integer()) :: Entry.t()
  def set_cell(%Entry{} = mutation, family, column, value, timestamp \\ -1)
      when is_binary(family) and is_binary(column) and is_integer(timestamp) do
    set_mutation =
      SetCell.new(
        family_name: family,
        column_qualifier: column,
        value: value,
        timestamp_micros: timestamp
      )

    add_mutation(mutation, :set_cell, set_mutation)
  end

  @doc """
  Creates a `Google.Bigtable.V2.Mutation.DeleteFromColumn` given a `Google.Bigtable.V2.Mutation`, family name, column qualifier, and time range.

  Time range is a keyword list that should contain optional start_timestamp_micros and end_timestamp_micros.
  If not provided, start is treated as 0 and end is treated as infinity

  ## Examples

      iex> Mutations.build("Row#123") |> Mutations.delete_from_column("family", "column")
      %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation: {:delete_from_column,
            %Google.Bigtable.V2.Mutation.DeleteFromColumn{
              column_qualifier: "column",
              family_name: "family",
              time_range: %Google.Bigtable.V2.TimestampRange{
                end_timestamp_micros: 0,
                start_timestamp_micros: 0
              }
            }}
          }
        ],
        row_key: "Row#123"
      }
  """
  @spec delete_from_column(Entry.t(), binary(), binary(), Keyword.t()) :: Entry.t()
  def delete_from_column(%Entry{} = mutation_struct, family, column, time_range \\ [])
      when is_binary(family) and is_binary(column) do
    time_range = create_time_range(time_range)

    mutation =
      DeleteFromColumn.new(
        family_name: family,
        column_qualifier: column,
        time_range: time_range
      )

    add_mutation(mutation_struct, :delete_from_column, mutation)
  end

  @doc """
  Creates a `Google.Bigtable.V2.Mutation.DeleteFromFamily` given a `Google.Bigtable.V2.Mutation` and family name.

  ## Examples

      iex> Mutations.build("Row#123") |> Mutations.delete_from_family("family")
      %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation: {:delete_from_family,
            %Google.Bigtable.V2.Mutation.DeleteFromFamily{family_name: "family"}}
          }
        ],
        row_key: "Row#123"
      }
  """
  @spec delete_from_family(Entry.t(), binary()) :: Entry.t()
  def delete_from_family(%Entry{} = mutation_struct, family) when is_binary(family) do
    mutation = DeleteFromFamily.new(family_name: family)

    add_mutation(mutation_struct, :delete_from_family, mutation)
  end

  @doc """
  Creates a `Google.Bigtable.V2.Mutation.DeleteFromRow` given a `Google.Bigtable.V2.Mutation`.

  ## Examples

      iex> Mutations.build("Row#123") |> Mutations.delete_from_row()
      %Google.Bigtable.V2.MutateRowsRequest.Entry{
        mutations: [
          %Google.Bigtable.V2.Mutation{
            mutation: {:delete_from_row, %Google.Bigtable.V2.Mutation.DeleteFromRow{}}
          }
        ],
        row_key: "Row#123"
      }
  """

  @spec delete_from_row(Entry.t()) :: Entry.t()
  def delete_from_row(%Entry{} = mutation_struct) do
    mutation = DeleteFromRow.new()

    add_mutation(mutation_struct, :delete_from_row, mutation)
  end

  # Adds an additional V2.Mutation to the given mutation struct
  @spec add_mutation(Entry.t(), atom(), Mutation.t()) :: Entry.t()
  defp add_mutation(%Entry{} = mutation_struct, type, mutation) do
    %{
      mutation_struct
      | mutations: mutation_struct.mutations ++ [Mutation.new(mutation: {type, mutation})]
    }
  end

  # Creates a time range that can be used for column deletes
  @spec create_time_range(Keyword.t()) :: TimestampRange.t()
  defp create_time_range(time_range) do
    start_timestamp_micros = Keyword.get(time_range, :start)
    end_timestamp_micros = Keyword.get(time_range, :end)

    time_range = TimestampRange.new()

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

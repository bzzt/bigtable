defmodule Bigtable.RowFilter do
  alias Google.Bigtable.V2.{ColumnRange, ReadRowsRequest, RowFilter, TimestampRange}

  @type column_range :: {binary(), binary(), boolean()} | {binary(), binary()}

  @moduledoc """
  Provides functions for creating `Google.Bigtable.V2.RowFilter` and applying them to a `Google.Bigtable.V2.ReadRowsRequest` or `Google.Bigtable.V2.RowFilter.Chain`.
  """

  @doc """
  Adds a `Google.Bigtable.V2.RowFilter` chain to a `Google.Bigtable.V2.ReadRowsRequest` given a list of `Google.Bigtable.V2.RowFilter`.

  ## Examples

      iex> filters = [Bigtable.RowFilter.cells_per_column(2), Bigtable.RowFilter.row_key_regex("^Test#\w+")]
      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowFilter.chain(filters)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
        %Google.Bigtable.V2.RowFilter.Chain{
          filters: [
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 2}
            },
            %Google.Bigtable.V2.RowFilter{
              filter: {:row_key_regex_filter, "^Test#\w+"}
            }
          ]
        }}
      }
  """
  @spec chain(ReadRowsRequest.t(), [RowFilter.t()]) :: ReadRowsRequest.t()
  def chain(%ReadRowsRequest{} = request, filters) when is_list(filters) do
    {:chain, RowFilter.Chain.new(filters: filters)}
    |> build_filter()
    |> apply_filter(request)
  end

  @doc """
  Adds a cells per column `Google.Bigtable.V2.RowFilter` to a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.cells_per_column(2)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter:  {:cells_per_column_limit_filter, 2}
      }
  """
  @spec cells_per_column(ReadRowsRequest.t(), integer()) :: ReadRowsRequest.t()
  def cells_per_column(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    filter = cells_per_column(limit)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a cells per column `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.cells_per_column(2)
      %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_column_limit_filter, 2}
      }
  """
  @spec cells_per_column(integer()) :: RowFilter.t()
  def cells_per_column(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> build_filter()
  end

  @doc """
  Adds a cells per row `Google.Bigtable.V2.RowFilter` to a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.cells_per_row(2)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter:  {:cells_per_row_limit_filter, 2}
      }
  """
  @spec cells_per_row(ReadRowsRequest.t(), integer()) :: ReadRowsRequest.t()
  def cells_per_row(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    filter = cells_per_row(limit)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a cells per row `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.cells_per_row(2)
      %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_row_limit_filter, 2}
      }
  """
  @spec cells_per_row(integer()) :: RowFilter.t()
  def cells_per_row(limit) when is_integer(limit) do
    {:cells_per_row_limit_filter, limit}
    |> build_filter()
  end

  @doc """
  Adds a cells per row offset `Google.Bigtable.V2.RowFilter` to a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.cells_per_row_offset(2)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter:  {:cells_per_row_offset_filter, 2}
      }
  """
  @spec cells_per_row_offset(ReadRowsRequest.t(), integer()) :: ReadRowsRequest.t()
  def cells_per_row_offset(%ReadRowsRequest{} = request, offset) when is_integer(offset) do
    filter = cells_per_row_offset(offset)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a cells per row offset `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.cells_per_row_offset(2)
      %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_row_offset_filter, 2}
      }
  """
  @spec cells_per_row_offset(integer()) :: RowFilter.t()
  def cells_per_row_offset(offset) when is_integer(offset) do
    {:cells_per_row_offset_filter, offset}
    |> build_filter()
  end

  @doc """
  Adds a row key regex `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.row_key_regex("^Test#\\w+")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:row_key_regex_filter, "^Test#\\w+"}
      }
  """
  @spec row_key_regex(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def row_key_regex(%ReadRowsRequest{} = request, regex) do
    filter = row_key_regex(regex)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a row key regex `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.row_key_regex("^Test#\\w+")
      %Google.Bigtable.V2.RowFilter{
        filter: {:row_key_regex_filter, "^Test#\\w+"}
      }
  """
  @spec row_key_regex(binary()) :: RowFilter.t()
  def row_key_regex(regex) do
    {:row_key_regex_filter, regex}
    |> build_filter()
  end

  @doc """
  Adds a value regex `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.value_regex("^test$")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:value_regex_filter, "^test$"}
      }
  """
  @spec value_regex(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def value_regex(%ReadRowsRequest{} = request, regex) do
    filter = value_regex(regex)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a value regex `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.value_regex("^test$")
      %Google.Bigtable.V2.RowFilter{
        filter: {:value_regex_filter, "^test$"}
      }
  """
  @spec value_regex(binary()) :: RowFilter.t()
  def value_regex(regex) do
    {:value_regex_filter, regex}
    |> build_filter()
  end

  @doc """
  Adds a family name regex `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.family_name_regex("^testFamily$")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:family_name_regex_filter, "^testFamily$"}
      }
  """
  @spec family_name_regex(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def family_name_regex(%ReadRowsRequest{} = request, regex) do
    filter = family_name_regex(regex)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a family name regex `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.family_name_regex("^testFamily$")
      %Google.Bigtable.V2.RowFilter{
        filter: {:family_name_regex_filter, "^testFamily$"}
      }
  """
  @spec family_name_regex(binary()) :: RowFilter.t()
  def family_name_regex(regex) do
    {:family_name_regex_filter, regex}
    |> build_filter()
  end

  @doc """
  Adds a column qualifier regex `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.column_qualifier_regex("^testColumn$")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:column_qualifier_regex_filter, "^testColumn$"}
      }
  """
  @spec column_qualifier_regex(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def column_qualifier_regex(%ReadRowsRequest{} = request, regex) do
    filter = column_qualifier_regex(regex)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a family name regex `Google.Bigtable.V2.RowFilter`.

  ## Examples
      iex> Bigtable.RowFilter.column_qualifier_regex("^testColumn$")
      %Google.Bigtable.V2.RowFilter{
        filter: {:column_qualifier_regex_filter, "^testColumn$"}
      }
  """
  @spec column_qualifier_regex(binary()) :: RowFilter.t()
  def column_qualifier_regex(regex) do
    {:column_qualifier_regex_filter, regex}
    |> build_filter()
  end

  @doc """
  Adds a column range `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.

  Column range should be provided in the format {start, end} or {start, end, inclusive}.

  Defaults to inclusive start and end column qualifiers.

  ## Examples
      iex> range = {"column2", "column4"}
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.column_range("family", range)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {
        :column_range_filter,
          %Google.Bigtable.V2.ColumnRange{
            end_qualifier: {:end_qualifier_closed, "column4"},
            family_name: "family",
            start_qualifier: {:start_qualifier_closed, "column2"}
          }
        }
      }
  """

  @spec column_range(
          Google.Bigtable.V2.ReadRowsRequest.t(),
          binary(),
          {binary(), binary()} | {binary(), binary(), boolean()}
        ) :: ReadRowsRequest.t()
  def column_range(
        %ReadRowsRequest{} = request,
        family_name,
        range
      ) do
    filter = column_range(family_name, range)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a column range `Google.Bigtable.V2.RowFilter`.

  Column range should be provided in the format {start, end} or {start, end, inclusive}.

  Defaults to inclusive start and end column qualifiers.

  ## Examples
      iex> range = {"column2", "column4"}
      iex> Bigtable.RowFilter.column_range("family", range)
      %Google.Bigtable.V2.RowFilter{
        filter: {
        :column_range_filter,
          %Google.Bigtable.V2.ColumnRange{
            end_qualifier: {:end_qualifier_closed, "column4"},
            family_name: "family",
            start_qualifier: {:start_qualifier_closed, "column2"}
          }
        }
      }
  """

  @spec column_range(binary(), {binary(), binary(), boolean()} | {binary(), binary()}) ::
          RowFilter.t()
  def column_range(family_name, range) do
    range = create_range(family_name, range)

    {:column_range_filter, range}
    |> build_filter()
  end

  @doc """
  Adds a timestamp range `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.

  `start_timestamp`: Inclusive lower bound. If left empty, interpreted as 0.
  `end_timestamp`: Exclusive upper bound. If left empty, interpreted as infinity.

  ## Examples
      iex> range = [start_timestamp: 1000, end_timestamp: 2000]
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.timestamp_range(range)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {
          :timestamp_range_filter,
          %Google.Bigtable.V2.TimestampRange{
            end_timestamp_micros: 2000,
            start_timestamp_micros: 1000
          }
        }
      }
  """
  @spec timestamp_range(ReadRowsRequest.t(), Keyword.t()) :: ReadRowsRequest.t()
  def timestamp_range(%ReadRowsRequest{} = request, timestamps) do
    filter = timestamp_range(timestamps)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a timestamp range `Google.Bigtable.V2.RowFilter`.

  `start_timestamp`: Inclusive lower bound. If left empty, interpreted as 0.
  `end_timestamp`: Exclusive upper bound. If left empty, interpreted as infinity.

  ## Examples
      iex> range = [start_timestamp: 1000, end_timestamp: 2000]
      iex> Bigtable.RowFilter.timestamp_range(range)
      %Google.Bigtable.V2.RowFilter{
        filter: {
          :timestamp_range_filter,
          %Google.Bigtable.V2.TimestampRange{
            end_timestamp_micros: 2000,
            start_timestamp_micros: 1000
          }
        }
      }
  """
  @spec timestamp_range(Keyword.t()) :: RowFilter.t()
  def timestamp_range(timestamps) do
    range =
      TimestampRange.new(
        start_timestamp_micros: Keyword.get(timestamps, :start_timestamp, 0),
        end_timestamp_micros: Keyword.get(timestamps, :end_timestamp, 0)
      )

    {:timestamp_range_filter, range}
    |> build_filter()
  end

  @doc """
  Adds a pass all `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.


  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.pass_all()
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:pass_all_filter, true}
      }
  """
  @spec pass_all(ReadRowsRequest.t()) :: ReadRowsRequest.t()
  def pass_all(%ReadRowsRequest{} = request) do
    filter = pass_all()

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a pass all `Google.Bigtable.V2.RowFilter`.

  Matches all cells, regardless of input. Functionally equivalent to leaving filter unset, but included for completeness.

  ## Examples
      iex> Bigtable.RowFilter.pass_all()
      %Google.Bigtable.V2.RowFilter{
        filter: {:pass_all_filter, true}
      }
  """
  @spec pass_all() :: RowFilter.t()
  def pass_all() do
    {:pass_all_filter, true}
    |> build_filter()
  end

  @doc """
  Adds a block all `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.


  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.block_all()
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:block_all_filter, true}
      }
  """
  @spec block_all(ReadRowsRequest.t()) :: ReadRowsRequest.t()
  def block_all(%ReadRowsRequest{} = request) do
    filter = block_all()

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a block all `Google.Bigtable.V2.RowFilter`.

  Does not match any cells, regardless of input. Useful for temporarily disabling just part of a filter.

  ## Examples
      iex> Bigtable.RowFilter.block_all()
      %Google.Bigtable.V2.RowFilter{
        filter: {:block_all_filter, true}
      }
  """
  @spec block_all() :: RowFilter.t()
  def block_all() do
    {:block_all_filter, true}
    |> build_filter()
  end

  @doc """
  Adds a strip value transformer Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.


  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.strip_value_transformer()
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:strip_value_transformer, true}
      }
  """
  @spec strip_value_transformer(ReadRowsRequest.t()) :: ReadRowsRequest.t()
  def strip_value_transformer(%ReadRowsRequest{} = request) do
    filter = strip_value_transformer()

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a strip value transformer `Google.Bigtable.V2.RowFilter`.


  ## Examples
      iex> Bigtable.RowFilter.strip_value_transformer()
      %Google.Bigtable.V2.RowFilter{
        filter: {:strip_value_transformer, true}
      }
  """
  @spec strip_value_transformer() :: RowFilter.t()
  def strip_value_transformer() do
    {:strip_value_transformer, true}
    |> build_filter()
  end

  @doc """
  Adds an apply label transformer Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`.


  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.apply_label_transformer("label")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:apply_label_transformer, "label"}
      }
  """
  @spec apply_label_transformer(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def apply_label_transformer(%ReadRowsRequest{} = request, label) do
    filter = apply_label_transformer(label)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates an apply label transformer `Google.Bigtable.V2.RowFilter`.
  ## Examples
      iex> Bigtable.RowFilter.apply_label_transformer("label")
      %Google.Bigtable.V2.RowFilter{
        filter: {:apply_label_transformer, "label"}
      }
  """
  @spec apply_label_transformer(binary()) :: RowFilter.t()
  def apply_label_transformer(label) do
    {:apply_label_transformer, label}
    |> build_filter()
  end

  # Creates a Bigtable.V2.RowFilter given a type and value
  @doc false
  @spec build_filter({atom(), any()}) :: RowFilter.t()
  defp build_filter({type, value}) when is_atom(type) do
    RowFilter.new(filter: {type, value})
  end

  @spec apply_filter(RowFilter.t(), ReadRowsRequest.t()) :: ReadRowsRequest.t()
  defp apply_filter(%RowFilter{} = filter, %ReadRowsRequest{} = request) do
    %{request | filter: filter}
  end

  @spec create_range(binary(), column_range) :: ColumnRange.t()
  def create_range(family_name, {start_qualifier, end_qualifier, inclusive}) do
    range = translate_range(start_qualifier, end_qualifier, inclusive)

    range
    |> Keyword.put(:family_name, family_name)
    |> ColumnRange.new()
  end

  def create_range(family_name, {start_qualifier, end_qualifier}) do
    create_range(family_name, {start_qualifier, end_qualifier, true})
  end

  @spec translate_range(binary(), binary(), boolean()) :: Keyword.t()
  defp translate_range(start_qualifier, end_qualifier, inclusive) do
    case inclusive do
      true -> inclusive_range(start_qualifier, end_qualifier)
      false -> exclusive_range(start_qualifier, end_qualifier)
    end
  end

  @spec exclusive_range(binary(), binary()) :: Keyword.t()
  defp exclusive_range(start_qualifier, end_qualifier) do
    [
      start_qualifier: {:start_qualifier_open, start_qualifier},
      end_qualifier: {:end_qualifier_open, end_qualifier}
    ]
  end

  @spec inclusive_range(binary(), binary()) :: Keyword.t()
  defp inclusive_range(start_qualifier, end_qualifier) do
    [
      start_qualifier: {:start_qualifier_closed, start_qualifier},
      end_qualifier: {:end_qualifier_closed, end_qualifier}
    ]
  end
end

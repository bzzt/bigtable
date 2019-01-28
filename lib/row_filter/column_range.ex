defmodule Bigtable.RowFilter.ColumnRange do
  @moduledoc false
  alias Google.Bigtable.V2.ColumnRange

  @type column_range :: {binary(), binary(), boolean()} | {binary(), binary()}

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
      end_qualifier: {:start_qualifier_closed, end_qualifier}
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

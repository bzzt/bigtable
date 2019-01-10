defmodule Bigtable.RowRange do
  alias Google.Bigtable.V2

  @doc """
  Creates a RowRange excluding the provided start and end row keys
  """
  @spec exclusive(binary(), binary()) :: %{:__struct__ => atom(), optional(atom()) => any()}
  def exclusive(start_key, end_key) when is_binary(start_key) and is_binary(end_key) do
    V2.RowRange.new(
      start_key: {:start_key_open, start_key},
      end_key: {:end_key_open, end_key}
    )
  end

  @doc """
  Creates a RowRange including the provided start and end row keys
  """
  @spec inclusive(binary(), binary()) :: %{:__struct__ => atom(), optional(atom()) => any()}
  def inclusive(start_key, end_key) when is_binary(start_key) and is_binary(end_key) do
    V2.RowRange.new(
      start_key: {:start_key_closed, start_key},
      end_key: {:end_key_closed, end_key}
    )
  end
end

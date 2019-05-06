defmodule Bigtable.Connection do
  @moduledoc false
  use GenServer
  ## Client API
  def start_link(_opts) do
    DBConnection.start_link(Bigtable.Protocol, pool_size: 20, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end
end

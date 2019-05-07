defmodule Bigtable.Connection do
  @moduledoc false
  use GenServer

  @default_opts [
    pool_size: 40,
    queue_target: 100,
    queue_interval: 5000,
    name: __MODULE__
  ]
  ## Client API
  def start_link(_) do
    conn_opts = Application.get_env(:bigtable, :connection, [])

    DBConnection.start_link(
      Bigtable.Protocol,
      Keyword.merge(@default_opts, conn_opts)
    )
  end

  def init(state) do
    {:ok, state}
  end
end

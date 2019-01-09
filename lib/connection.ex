defmodule Bigtable.Connection do
  use GenServer

  ## Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  # Server Callbacks
  def init(:ok) do
    host = Application.get_env(:bigtable, :host)
    port = Application.get_env(:bigtable, :port)

    {:ok, channel} =
      GRPC.Stub.connect(host <> ":" <> to_string(port), interceptors: [GRPC.Logger.Client])

    {:ok, channel}
  end

  def handle_call(:get_connection, _from, state) do
    {:reply, state, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

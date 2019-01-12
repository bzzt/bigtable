defmodule Bigtable.Connection do
  @moduledoc """
    Holds the configured gRPC connection to Bigtable
  """
  use GenServer

  ## Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieves the gRPC connection Channel struct
  """
  @spec get_connection() :: GRPC.Channel.t()
  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  # Server Callbacks
  @spec init(:ok) :: {:ok, GRPC.Channel.t()}
  def init(:ok) do
    # Fetches the host and port to use for Bigtable gRPC connection
    host = Application.get_env(:bigtable, :host)
    port = Application.get_env(:bigtable, :port)

    # Connects the stub to the Bigtable gRPC server
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

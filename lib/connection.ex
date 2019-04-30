defmodule Bigtable.Connection do
  @moduledoc false
  use GenServer
  ## Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Connects to Bigtable and returns a `GRPC.Channel`.
  """
  @spec connect() :: GRPC.Channel.t()
  def connect do
    GenServer.call(__MODULE__, :connect)
  end

  @doc """
  Disconnects from the provided `GRPC.Channel`.
  """
  @spec disconnect(GRPC.Channel.t()) :: :ok
  def disconnect(channel) do
    GenServer.cast(__MODULE__, {:disconnect, channel})
  end
end

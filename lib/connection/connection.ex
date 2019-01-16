defmodule Bigtable.Connection do
  @moduledoc """
    Holds the configured gRPC connection to Bigtable
  """
  use GenServer

  @default_host "bigtable.googleapis.com:443"

  ## Client API
  @doc false

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the configured `GRPC.Channel`
  """
  @spec get_connection() :: GRPC.Channel.t()
  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  # Server Callbacks
  @doc false
  @spec init(:ok) :: {:ok, GRPC.Channel.t()}
  def init(:ok) do
    # Fetches the url to use for Bigtable gRPC connection
    endpoint =
      case get_custom_endpoint() do
        nil -> @default_host
        custom -> custom
      end

    opts = [interceptors: [GRPC.Logger.Client]]

    opts =
      case Application.get_env(:bigtable, :ssl, true) do
        true ->
          opts ++
            [
              cred: %GRPC.Credential{
                ssl: []
              }
            ]

        false ->
          opts
      end

    # Connects the stub to the Bigtable gRPC server
    {:ok, channel} =
      GRPC.Stub.connect(
        endpoint,
        opts
      )

    {:ok, channel}
  end

  def handle_call(:get_connection, _from, state) do
    {:reply, state, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp get_custom_endpoint() do
    env = System.get_env("BIGTABLE_EMULATOR_HOST")
    custom = Application.get_env(:bigtable, :endpoint, env)

    case custom do
      nil ->
        nil

      endpoint ->
        endpoint
    end
  end
end

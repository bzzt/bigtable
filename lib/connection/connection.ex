defmodule Bigtable.Connection do
  @moduledoc """
    Holds the configured gRPC connection to Bigtable
  """
  use GenServer

  alias Bigtable.Connection.Auth

  @default_host "bigtable.googleapis.com:443"
  @default_opts []

  ## Client API
  @doc false

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the configured `GRPC.Channel`
  """
  @spec connect() :: GRPC.Channel.t()
  def connect do
    GenServer.call(__MODULE__, :connect)
  end

  def disconnect(channel) do
    GenServer.cast(__MODULE__, {:disconnect, channel})
  end

  @spec get_metadata() :: Keyword.t()
  def get_metadata do
    token = Auth.get_token()
    metadata = %{authorization: "Bearer #{token.token}"}
    [metadata: metadata, content_type: "application/grpc", return_headers: true]
  end

  # Server Callbacks
  @doc false
  @spec init(:ok) :: {:ok, map()}
  def init(:ok) do
    # Fetches the url to use for Bigtable gRPC connection
    endpoint =
      case get_custom_endpoint() do
        nil -> @default_host
        custom -> custom
      end

    opts = build_opts()

    # Connects the stub to the Bigtable gRPC server

    {:ok, %{endpoint: endpoint, opts: opts}}
  end

  def handle_call(:connect, _from, %{endpoint: endpoint, opts: opts} = state) do
    {:ok, channel} =
      GRPC.Stub.connect(
        endpoint,
        opts
      )

    {:reply, channel, state}
  end

  def handle_cast({:disconnect, channel}, state) do
    GRPC.Stub.disconnect(channel)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp build_opts do
    case Application.get_env(:bigtable, :ssl, true) do
      true ->
        @default_opts ++
          [
            cred: %GRPC.Credential{
              ssl: []
            }
          ]

      false ->
        @default_opts
    end
  end

  def get_custom_endpoint do
    env = System.get_env("BIGTABLE_EMULATOR_HOST")
    custom = Application.get_env(:bigtable, :endpoint, nil)

    case env do
      nil ->
        custom

      endpoint ->
        endpoint
    end
  end
end

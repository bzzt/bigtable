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
  @spec get_connection() :: GRPC.Channel.t()
  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  @spec get_metadata() :: Keyword.t()
  def get_metadata do
    token = Auth.get_token()
    metadata = %{authorization: "Bearer #{token.token}"}
    [metadata: metadata, content_type: "application/grpc"]
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

    opts = build_opts()

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

  defp get_custom_endpoint do
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

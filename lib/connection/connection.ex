defmodule Bigtable.Connection do
  @moduledoc """
    Holds the configured gRPC connection to Bigtable
  """
  use GenServer

  defstruct data: nil, instance_admin: nil, table_admin: nil

  @defaultBaseUrl "bigtable.googleapis.com"
  @defaultAdminBaseUrl "bigtableadmin.googleapis.com"

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
    # base_url =
    #   case custom_endpoint() do
    #     nil -> @defaultBaseUrl
    #     custom -> custom
    #   end

    # Connects the stub to the Bigtable gRPC server
    {:ok, channel} =
      GRPC.Stub.connect(@defaultBaseUrl, 443,
        interceptors: [GRPC.Logger.Client],
        cred: %GRPC.Credential{
          ssl: []
        }
      )

    {:ok, channel}
    # {:ok, build_endpoints()}
  end

  def handle_call(:get_connection, _from, state) do
    {:reply, state, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp build_endpoints() do
    %__MODULE__{
      data: build_endpoint(@defaultBaseUrl, 443),
      instance_admin: build_endpoint(@defaultAdminBaseUrl, 443),
      table_admin: build_endpoint(@defaultAdminBaseUrl, 443)
    }
  end

  defp build_endpoint(default_url, default_port, options \\ %Bigtable.Connection.Config.Options{}) do
    custom_endpoint = get_custom_endpoint()

    %Bigtable.Connection.Config{
      client_config: %{},
      service_path: Map.get(custom_endpoint, :host, default_url),
      port: Map.get(custom_endpoint, :port, default_port),
      ssl_creds: Map.get(custom_endpoint, :creds, nil),
      options: options
    }
  end

  defp get_custom_endpoint() do
    env = System.get_env("BIGTABLE_EMULATOR_HOST")
    custom = Application.get_env(:bigtable, :endpoint, env)

    case custom do
      nil ->
        %{}

      endpoint ->
        split = String.split(endpoint, ":")
        %{host: split[0], port: split[1], ssl_creds: "placeholder"}
    end
  end
end

defmodule Bigtable.Connection do
  @moduledoc false

  use GenServer
  @default_endpoint "bigtable.googleapis.com:443"

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

  # Server Callbacks
  @spec init(:ok) :: {:ok, map()}
  def init(:ok) do
    {:ok, %{endpoint: get_endpoint(), opts: build_opts()}}
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

  @spec get_endpoint() :: binary()
  def get_endpoint do
    emulator = System.get_env("BIGTABLE_EMULATOR_HOST")
    endpoint = Application.get_env(:bigtable, :endpoint, @default_endpoint)

    if emulator != nil do
      emulator
    else
      endpoint
    end
  end

  @spec build_opts() :: list()
  defp build_opts do
    case Application.get_env(:bigtable, :ssl, []) do
      [] ->
        []

      opts ->
        [
          cred: %GRPC.Credential{
            ssl: opts ++ default_ssl_opts()
          }
        ]
    end
  end

  defp default_ssl_opts() do
    [
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      ]
    ]
  end
end

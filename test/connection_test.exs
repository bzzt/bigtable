defmodule ConnectionTest do
  alias Bigtable.Connection
  use ExUnit.Case

  doctest Connection

  describe "Connection.get_connection() " do
    test "should return a Channel struct" do
      [host, port] =
        Connection.get_custom_endpoint()
        |> String.split(":")

      expected = %GRPC.Channel{
        adapter: GRPC.Adapter.Gun,
        adapter_payload: %{conn_pid: "MockPid"},
        cred: nil,
        host: host,
        port: String.to_integer(port),
        scheme: "http"
      }

      connection = Connection.get_connection()

      result = %{
        connection
        | adapter_payload: %{connection.adapter_payload | conn_pid: "MockPid"}
      }

      assert result == expected
    end
  end
end

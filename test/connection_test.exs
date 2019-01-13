defmodule ConnectionTest do
  alias Bigtable.Connection
  use ExUnit.Case

  describe "Connection.get_connection() " do
    test "should return a Channel struct" do
      expected = %GRPC.Channel{
        adapter: GRPC.Adapter.Gun,
        adapter_payload: %{conn_pid: "MockPid"},
        cred: nil,
        host: "localhost",
        interceptors: [{GRPC.Logger.Client, :info}],
        port: 8086,
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

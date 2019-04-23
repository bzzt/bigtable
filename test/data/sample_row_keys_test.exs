defmodule SampleRowKeysTest do
  @moduledoc false
  alias Bigtable.Data.SampleRowKeys

  use ExUnit.Case

  doctest SampleRowKeys

  describe "SampleRowKeys.build()" do
    test "should build a SampleRowKeysRequest with configured table" do
      assert SampleRowKeys.build() == expected_request()
    end

    test "should build a ReadRowsRequest with custom table" do
      table_name = "custom-table"

      assert SampleRowKeys.build(table_name) == expected_request(table_name)
    end
  end

  defp expected_request(table_name \\ Bigtable.Utils.configured_table_name()) do
    %Google.Bigtable.V2.SampleRowKeysRequest{
      app_profile_id: "",
      table_name: table_name
    }
  end
end

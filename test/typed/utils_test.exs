defmodule UtilsTest do
  @moduledoc false
  alias Bigtable.Typed.Utils

  use ExUnit.Case

  doctest Utils

  describe "Utils.row_key_properties" do
    test "returns single property when no hash present" do
      expected = ["test.id"]
      result = Utils.row_key_properties("test.id")
      assert result == expected
    end

    test "returns multiple properties when hash present" do
      expected = ["test.a", "test.b"]
      result = Utils.row_key_properties("test.a#test.b")
      assert result == expected
    end
  end

  describe "Utils.build_update_key" do
    setup do
      [
        prefix: "Entity",
        entity: %{
          family: %{
            id: "123",
            nested: %{
              value: "abc"
            }
          }
        }
      ]
    end

    test "returns correct key for single property", context do
      pattern = ["family.id"]

      expected = "Entity#123"

      result = Utils.build_update_key(pattern, context.prefix, context.entity)

      assert result == expected
    end
  end
end

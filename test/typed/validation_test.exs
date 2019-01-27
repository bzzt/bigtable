defmodule ValidationTest do
  @moduledoc false
  alias Bigtable.Typed.Validation

  use ExUnit.Case

  doctest Validation

  describe "Validation.validate_map!" do
    setup do
      [
        type_spec: %{
          family_a: %{
            column_a: :integer,
            column_b: :boolean
          },
          family_b: %{
            column_a: :map,
            column_b: %{
              nested: :boolean
            }
          }
        }
      ]
    end

    test "should return :ok for valid primitives", context do
      map = %{
        family_a: %{
          column_a: 1,
          column_b: true
        }
      }

      assert Validation.validate_map!(context.type_spec, map) == :ok
    end

    test "should raise for invalid primitives", context do
      map = %{
        family_a: %{
          column_a: true,
          column_b: 1
        }
      }

      assert_raise(RuntimeError, fn -> Validation.validate_map!(context.type_spec, map) end)
    end

    test "should return :ok for valid typed map value", context do
      map = %{
        family_b: %{
          column_b: %{
            nested: true
          }
        }
      }

      assert Validation.validate_map!(context.type_spec, map) == :ok
    end

    test "should raise for invalid typed map", context do
      map = %{
        family_b: %{
          column_b: %{
            nested: 1
          }
        }
      }

      assert_raise(RuntimeError, fn -> Validation.validate_map!(context.type_spec, map) end)
    end

    test "should return :ok for valid untyped map", context do
      map = %{
        family_b: %{
          column_a: %{
            foo: "bar"
          }
        }
      }

      assert Validation.validate_map!(context.type_spec, map) == :ok
    end

    test "should return :ok with extra untyped fields", context do
      map = %{
        family_b: %{
          column_c: "untyped",
          column_d: %{
            foo: "bar"
          }
        },
        family_c: %{
          column_a: "untyped"
        }
      }

      assert Validation.validate_map!(context.type_spec, map) == :ok
    end
  end

  describe "Validation.valid?" do
    test "should return true for valid types" do
      results = [
        Validation.valid?(:string, "string"),
        Validation.valid?(:boolean, true),
        Validation.valid?(:integer, 1),
        Validation.valid?(:float, 1.1),
        Validation.valid?(:list, [1, 2, 3]),
        Validation.valid?(:map, %{a: 1})
      ]

      assert Enum.all?(results, &(&1 == true))
    end

    test "should return false for invalid types" do
      results = [
        Validation.valid?(:string, 1),
        Validation.valid?(:boolean, "false"),
        Validation.valid?(:integer, "1"),
        Validation.valid?(:float, true),
        Validation.valid?(:list, 2.5),
        Validation.valid?(:map, [1, 2, 3])
      ]

      assert Enum.all?(results, &(&1 == false))
    end

    test "should return true for nil values" do
      results = [
        Validation.valid?(:string, nil),
        Validation.valid?(:integer, nil),
        Validation.valid?(:float, nil),
        Validation.valid?(:list, nil),
        Validation.valid?(:map, nil)
      ]

      assert Enum.all?(results, &(&1 == true))
    end
  end
end

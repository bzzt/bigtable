defmodule SchemaTest do
  use ExUnit.Case

  doctest Bigtable.Schema

  defmodule TestType do
    use Bigtable.Schema

    type do
      column(:a, :integer)
      column(:b, :boolean)
    end
  end

  defmodule TestSchema do
    use Bigtable.Schema

    row :entity do
      family :family_a do
        column(:a, :string)
        column(:b, :map)
      end

      family :family_b do
        column(:a, :boolean)
      end
    end
  end

  describe "Schema" do
    test "should properly generate a type" do
      expected = %TestType{
        a: :integer,
        b: :boolean
      }

      assert TestType.type() == expected
    end

    test "should properly generate a row" do
      expected = %TestSchema{
        family_a: %{
          a: :string,
          b: :map
        },
        family_b: %{
          a: :boolean
        }
      }

      assert TestSchema.type() == expected
    end
  end
end

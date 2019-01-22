defmodule SchemaTest do
  use ExUnit.Case

  doctest Bigtable.Schema

  defmodule OneColumnType do
    use Bigtable.Schema

    type do
      column(:a, :integer)
    end
  end

  defmodule TwoColumnType do
    use Bigtable.Schema

    type do
      column(:a, :integer)
      column(:b, :boolean)
    end
  end

  defmodule TestSchema do
    use Bigtable.Schema

    @update_patterns ["family_a.a"]

    row :entity do
      family :family_a do
        column(:a, :string)
        column(:b, :map)
      end
    end
  end

  defmodule TestSchemaWithType do
    use Bigtable.Schema

    @update_patterns ["family_a.a"]

    row :entity do
      family :family_a do
        column(:a, :string)
        column(:b, :map)
      end

      family :family_b do
        column(:a, SchemaTest.OneColumnType)
        column(:b, SchemaTest.TwoColumnType)
      end
    end
  end

  describe "Schema - Type" do
    test "should generate a type with multiple columns" do
      expected = %SchemaTest.TwoColumnType{
        a: :integer,
        b: :boolean
      }

      assert SchemaTest.TwoColumnType.type() == expected
    end

    test "should generate a type with a single column" do
      expected = %SchemaTest.OneColumnType{
        a: :integer
      }

      assert SchemaTest.OneColumnType.type() == expected
    end
  end

  describe "Schema - Row" do
    test "should generate a row with scalar types" do
      expected = %SchemaTest.TestSchema{
        family_a: %{
          a: :string,
          b: :map
        }
      }

      assert SchemaTest.TestSchema.type() == expected
    end
  end

  test "should generate a row with schema types" do
    expected = %SchemaTest.TestSchemaWithType{
      family_a: %{
        a: :string,
        b: :map
      },
      family_b: %{
        a: %SchemaTest.OneColumnType{
          a: :integer
        },
        b: %SchemaTest.TwoColumnType{
          a: :integer,
          b: :boolean
        }
      }
    }

    assert SchemaTest.TestSchemaWithType.type() == expected
  end
end

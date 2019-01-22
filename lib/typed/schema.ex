defmodule Bigtable.Schema do
  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :rows, accumulate: true)
      Module.register_attribute(__MODULE__, :families, accumulate: true)
      Module.register_attribute(__MODULE__, :columns, accumulate: true)
    end
  end

  defmacro type(do: block) do
    quote do
      var!(columns) = []
      unquote(block)

      defstruct var!(columns)

      def type() do
        %__MODULE__{}
      end
    end
  end

  defmacro row(name, do: block) do
    quote do
      @prefix "#{String.capitalize(to_string(unquote(name)))}"
      unquote(block)
      defstruct @families

      def get_all() do
        Bigtable.Typed.Get.get_all(@prefix)
        |> parse_result()
      end

      def get_by_id(ids) when is_list(ids) do
        Bigtable.Typed.Get.get_by_id(ids, @prefix)
        |> parse_result()
      end

      def get_by_id(id) when is_binary(id) do
        get_by_id([id])
      end

      def update(maps) when is_list(maps) do
        Bigtable.Typed.Update.mutations_from_maps(maps, @prefix, @update_patterns)
      end

      def update(map) when is_map(map) do
        update([map])
      end

      def delete(ids) when is_list(ids) do
        Bigtable.Typed.Delete.delete_rows(ids, @prefix)
      end

      def delete(id) when is_binary(id) do
        delete([id])
      end

      def parse_result(result) do
        Bigtable.Typed.parse_result(result, __MODULE__.type())
      end

      def type() do
        %__MODULE__{}
      end
    end
  end

  defmacro family(name, do: block) do
    quote do
      var!(columns) = []
      unquote(block)
      @families {unquote(name), Map.new(var!(columns))}
    end
  end

  defmacro column(key, value) do
    c = {key, get_value_type(value)} |> Macro.escape()

    quote do
      var!(columns) = [unquote(c) | var!(columns)]
    end
  end

  defp get_value_type(value) when is_atom(value), do: value

  defp get_value_type({:__aliases__, _, modules}) do
    Module.concat([Elixir | modules]).type()
  end
end

defmodule BT.Schema.PositionTest do
  use Bigtable.Schema

  type do
    column(:bearing, :integer)
    column(:latitude, :float)
    column(:longitude, :float)
    column(:timestamp, :string)
  end
end

defmodule BT.Schema.VehicleTest do
  use Bigtable.Schema

  @update_patterns ["vehicle.id"]

  row :vehicle do
    family :vehicle do
      column(:battery, :integer)
      column(:checkedInAt, :string)
      column(:condition, :string)
      column(:driver, :string)
      column(:fleet, :string)
      column(:id, :string)
      column(:numberPlate, :string)
      column(:position, BT.Schema.PositionTest)
      column(:previousPosition, BT.Schema.PositionTest)
      column(:ride, :string)
    end
  end
end

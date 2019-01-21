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

      def get(ids) do
        rows =
          [ids]
          |> List.flatten()
          |> Enum.map(fn id -> "#{@prefix}##{id}" end)
          |> Bigtable.RowSet.row_keys()
          |> Bigtable.ReadRows.read()
          |> Enum.map(fn {:ok, rows} -> rows.chunks end)
          |> List.flatten()
          |> Bigtable.Typed.group_by_row_key()
          |> Map.new(fn {key, value} -> {key, parse(value)} end)
      end

      def parse(row) do
        Bigtable.Typed.parse_typed(__MODULE__.type(), row)
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

defmodule BT.Schema.Position do
  use Bigtable.Schema

  type do
    column(:latitude, :float)
    column(:longitude, :float)
    column(:timestamp, :binary)
  end
end

defmodule BT.Schema.Vehicle do
  use Bigtable.Schema

  row :vehicle do
    family :vehicle do
      column(:battery, :integer)
      column(:condition, :binary)
      column(:driver, :binary)
      column(:fleet, :binary)
      column(:numberPlate, :binary)
      column(:ride, :binary)
      column(:position, BT.Schema.Position)
      column(:previousPosition, BT.Schema.Position)
    end
  end
end

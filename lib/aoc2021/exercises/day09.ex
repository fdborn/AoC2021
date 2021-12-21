defmodule Aoc2021.Exercises.Day09 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise
    alias Aoc2021.Exercises.Day09.HeightMap

    exercise "Part 1" do
      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.graphemes()
          |> Enum.map(&String.to_integer/1)
        end)
      end)

      step("Build heightmap", fn input ->
        map_cells =
          Enum.with_index(input)
          |> Enum.flat_map(fn {line, y} ->
            line
            |> Enum.with_index()
            |> Enum.map(fn {value, x} -> {{x, y}, value} end)
          end)
          |> Enum.into(%{})

        HeightMap.new(map_cells)
      end)

      step("Find low points", fn map ->
        low_points = HeightMap.low_points(map)

        %{
          map: map,
          low_points: low_points
        }
      end)

      step("Sum risk levels", fn input ->
        input.low_points
        |> Enum.map(&(HeightMap.get(input.map, &1) + 1))
        |> Enum.sum()
      end)
    end
  end

  defmodule Part2 do
    use Exercise
    alias Aoc2021.Exercises.Day09.HeightMap

    exercise "Part 2" do
      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.graphemes()
          |> Enum.map(&String.to_integer/1)
        end)
      end)

      step("Build heightmap", fn input ->
        map_cells =
          Enum.with_index(input)
          |> Enum.flat_map(fn {line, y} ->
            line
            |> Enum.with_index()
            |> Enum.map(fn {value, x} -> {{x, y}, value} end)
          end)
          |> Enum.into(%{})

        HeightMap.new(map_cells)
      end)

      step("Find basins", fn map ->
        basins = HeightMap.basins(map)

        %{
          map: map,
          basins: basins,
        }
      end)

      step("Multiply the top three sizes", fn input ->
        input.basins
        |> Enum.map(&length/1)
        |> Enum.sort(&>=/2)
        |> Enum.take(3)
        |> Enum.reduce(&*/2)
      end)
    end
  end

  defmodule HeightMap do
    defstruct cells: %{}

    def new(cells) do
      %__MODULE__{
        cells: cells
      }
    end

    def get(%__MODULE__{cells: cells}, point), do: cells[point]

    def low_points(%__MODULE__{cells: cells}) do
      cells
      |> Enum.reduce([], fn {point, height}, low_points ->
        surrounding_heights =
          get_adjacent(cells, point)
          |> Enum.map(&cells[&1])

        low_point? = Enum.all?(surrounding_heights, fn neightbour -> neightbour > height end)

        if low_point? do
          [point | low_points]
        else
          low_points
        end
      end)
    end

    def basins(%__MODULE{cells: cells} = map) do
      low_points(map)
      |> Enum.map(fn low_point ->
        do_basin(cells, low_point, [])
        |> Enum.uniq()
      end)
    end

    defp do_basin(cells, point, members) do
      members = [point | members]

      adjacent =
        cells
        |> get_adjacent(point)
        |> Enum.reject(&(cells[&1] == 9))

      (adjacent -- members)
      |> Enum.reduce(members, fn point, members -> do_basin(cells, point, members) end)
    end

    defp get_adjacent(cells, {x, y}) do
      horizontal = [{x - 1, y}, {x + 1, y}]
      vertical = [{x, y - 1}, {x, y + 1}]

      (horizontal ++ vertical)
      |> Enum.reject(&is_nil(cells[&1]))
    end
  end
end

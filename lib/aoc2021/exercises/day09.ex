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

      step("Build heightmap", Aoc2021.Exercises.Day09.HeightMapRenderer, fn input ->
        map_cells =
          Enum.with_index(input)
          |> Enum.flat_map(fn {line, y} ->
            line
            |> Enum.with_index()
            |> Enum.map(fn {value, x} -> {{x, y}, value} end)
          end)
          |> Enum.into(%{})

        %{
          map: HeightMap.new(map_cells)
        }
      end)

      step("Find low points", Aoc2021.Exercises.Day09.HeightMapRenderer, fn input ->
        low_points = HeightMap.low_points(input.map)

        %{
          map: input.map,
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

      step("Build heightmap", Aoc2021.Exercises.Day09.HeightMapRenderer, fn input ->
        map_cells =
          Enum.with_index(input)
          |> Enum.flat_map(fn {line, y} ->
            line
            |> Enum.with_index()
            |> Enum.map(fn {value, x} -> {{x, y}, value} end)
          end)
          |> Enum.into(%{})

        %{
          map: HeightMap.new(map_cells)
        }
      end)

      step("Find basins", Aoc2021.Exercises.Day09.HeightMapRenderer, fn input ->
        basins = HeightMap.basins(input.map)

        %{
          map: input.map,
          basins: basins
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

  defmodule HeightMapRenderer do
    @behaviour Exercise.Renderer

    @impl true
    def render(result, _meta) do
      alias VegaLite, as: Vl

      {map, result} = Map.pop(result, :map)

      data =
        map.cells
        |> Enum.map(fn {{x, y}, height} -> %{x: x, y: y, height: height} end)

      heightmap =
        Vl.new(width: "container", height: "500")
        |> Vl.mark(:rect, tooltip: true)
        |> Vl.data_from_values(data)
        |> Vl.encode_field(:x, "x", type: :ordinal)
        |> Vl.encode_field(:y, "y", type: :ordinal)
        |> Vl.encode_field(:fill, "height", type: :quantitative)

      low_points =
        if low_points = result[:low_points] do
          low_point_data =
            low_points
            |> Enum.map(fn {x, y} -> %{x: x, y: y} end)

          Vl.new(width: "container", height: "500")
          |> Vl.mark(:rect, fill: "rgba(255,0,0,0.5)", tooltip: true)
          |> Vl.data_from_values(low_point_data)
          |> Vl.encode_field(:x, "x", type: :ordinal)
          |> Vl.encode_field(:y, "y", type: :ordinal)
        end

      basins =
        if basins = result[:basins] do
          basins_data =
            basins
            |> Enum.with_index()
            |> Enum.flat_map(fn {basin_points, index} ->
              basin_points
              |> Enum.map(fn {x, y} -> %{x: x, y: y, basin: index} end)
            end)

          Vl.new(width: "container", height: "500")
          |> Vl.mark(:rect, fill_opacity: 0.5)
          |> Vl.data_from_values(basins_data)
          |> Vl.encode_field(:x, "x", type: :ordinal)
          |> Vl.encode_field(:y, "y", type: :ordinal)
          |> Vl.encode_field(:color, "basin", type: :nominal)
        end

      layers =
        [heightmap, low_points, basins]
        |> Enum.reject(&is_nil/1)

      spec =
        Vl.new(width: "container", height: "500")
        |> Vl.layers(layers)
        |> Vl.Export.to_json()

      view_data = %{
        result: result,
        spec: spec
      }

      {Aoc2021Web.RendererComponents.VegaLite, view_data}
    end
  end
end

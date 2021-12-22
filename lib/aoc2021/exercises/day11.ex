defmodule Aoc2021.Exercises.Day11 do
  alias Aoc2021.Exercise
  alias Aoc2021.Exercises.Day11.OctoGrid

  defmodule Part1 do
    use Exercise

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

      step("Build initial grid", Aoc2021.Exercises.Day11.OctoGridRenderer, fn input ->
        grid =
          input
          |> Enum.with_index()
          |> Enum.flat_map(fn {line, y} ->
            line
            |> Enum.with_index()
            |> Enum.map(fn {value, x} -> {{x, y}, value} end)
          end)
          |> Enum.into(%{})
          |> OctoGrid.new()

        %{
          grid: grid
        }
      end)

      step(
        "Simulate steps and get total flashes",
        Aoc2021.Exercises.Day11.OctoGridRenderer,
        fn input ->
          {_, total_flashes, hist} =
            for _ <- 1..100, reduce: {input.grid, 0, [input.grid]} do
              {grid, total_flashes, hist} ->
                {grid, flashes} = OctoGrid.step(grid)

                {grid, total_flashes + flashes, [grid | hist]}
            end

          %{
            total_flashes: total_flashes,
            grids: Enum.reverse(hist)
          }
        end
      )
    end
  end

  defmodule Part2 do
    use Exercise

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

      step("Build initial grid", Aoc2021.Exercises.Day11.OctoGridRenderer, fn input ->
        grid =
          input
          |> Enum.with_index()
          |> Enum.flat_map(fn {line, y} ->
            line
            |> Enum.with_index()
            |> Enum.map(fn {value, x} -> {{x, y}, value} end)
          end)
          |> Enum.into(%{})
          |> OctoGrid.new()

        %{
          grid: grid
        }
      end)

      defp step_until_sync(grid, step, prev) do
        if OctoGrid.synchronized?(grid) do
          {step, prev}
        else
          {next_grid, _} = OctoGrid.step(grid)
          step_until_sync(next_grid, step + 1, [next_grid | prev])
        end
      end

      step("Simulate steps until all flash simultaneously", Aoc2021.Exercises.Day11.OctoGridRenderer, fn input ->
        {step, hist} = step_until_sync(input.grid, 0, [input.grid])

        %{
          step: step,
          grids: Enum.reverse(hist),
        }
      end)
    end
  end

  defmodule OctoGrid do
    defstruct cells: {}

    def new(cells), do: %__MODULE__{cells: cells}

    def step(%__MODULE__{cells: cells} = grid) do
      cells =
        cells
        |> Enum.map(fn {point, value} -> {point, value + 1} end)
        |> Enum.into(%{})
        |> flash()

      {cells, flashes} =
        cells
        |> Enum.map_reduce(0, fn
          {point, :flashed}, flashes -> {{point, 0}, flashes + 1}
          {_, _} = entry, flashes -> {entry, flashes}
        end)

      {%{grid | cells: Enum.into(cells, %{})}, flashes}
    end

    def synchronized?(%__MODULE__{cells: cells}) do
      Enum.all?(cells, fn {_, value} -> value == 0 end)
    end

    defp flash(cells) do
      flashing? =
        Enum.any?(cells, fn
          {_, value} when is_number(value) -> value > 9
          _ -> false
        end)

      unless flashing? do
        cells
      else
        cells
        |> Enum.reduce(cells, fn
          {_, value}, cells when value <= 9 ->
            cells

          {_, :flashed}, cells ->
            cells

          {point, _value}, cells ->
            adjacent(cells, point)
            |> Enum.reduce(cells, fn point, cells ->
              Map.update!(cells, point, fn
                :flashed -> :flashed
                n -> n + 1
              end)
            end)
            |> Map.put(point, :flashed)
        end)
        |> flash()
      end
    end

    defp adjacent(cells, {x, y}) do
      for x <- (x - 1)..(x + 1),
          y <- (y - 1)..(y + 1),
          point = {x, y},
          Map.has_key?(cells, point),
          do: point
    end
  end

  defmodule OctoGridRenderer do
    @behaviour Exercise.Renderer

    @impl true
    def render(result, _meta) do
      alias VegaLite, as: Vl

      first_grid = if grid = result[:grid], do: [grid], else: []
      {grids, result} = Map.pop(result, :grids, [])

      grids = first_grid ++ grids

      data =
        grids
        |> Enum.with_index()
        |> Enum.flat_map(fn {grid, step} -> format_grid_data(grid, step) end)

      spec =
        Vl.new(width: "container", height: "500")
        |> Vl.mark(:rect, tooltip: true)
        |> Vl.data_from_values(data)
        |> Vl.encode_field(:x, "x", type: :ordinal)
        |> Vl.encode_field(:y, "y", type: :ordinal)
        |> Vl.encode_field(:fill, "value", type: :quantitative, scale: [domain: [0, 9]])
        |> Vl.param("Step",
          value: length(grids) - 1,
          bind: [input: :range, min: 0, max: length(grids) - 1, step: 1]
        )
        |> Vl.transform(filter: "datum.step == Step")
        |> Vl.Export.to_json()

      view_data = %{
        result: result,
        spec: spec
      }

      {Aoc2021Web.RendererComponents.VegaLite, view_data}
    end

    defp format_grid_data(grid, step) do
      grid.cells
      |> Enum.map(fn {{x, y}, value} -> %{x: x, y: y, value: value, step: step} end)
    end
  end
end

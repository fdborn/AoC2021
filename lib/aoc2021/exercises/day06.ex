defmodule Aoc2021.Exercises.Day06 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise

    @cycle 7
    @initial_cycle 9

    exercise "Part 1" do
      step("Preprocess input", fn input ->
        input
        |> String.trim()
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

      step("Create list of cycles with input", fn input ->
        cycles = for _ <- 1..@initial_cycle, do: 0

        input
        |> Enum.frequencies()
        |> Enum.reduce(cycles, fn {cycle, amount}, cycles ->
          List.replace_at(cycles, cycle, amount)
        end)
      end)

      step("Simulate fish growth", Aoc2021.Exercises.Day06.GrowthRenderer, fn input ->
        days = 80

        {cycles, history} =
          for day <- 1..days, reduce: {input, []} do
            {cycles, history} ->
              new_cycles = simulate_day(cycles)
              {new_cycles, [{day, new_cycles} | history]}
          end

        %{
          population: Enum.sum(cycles),
          history: history
        }
      end)

      def simulate_day(cycles) do
        {spawning, cycles} = List.pop_at(cycles, 0)
        cycles = cycles ++ [spawning]

        List.update_at(cycles, @cycle - 1, fn number -> number + spawning end)
      end
    end
  end

  defmodule Part2 do
    use Exercise
    alias Aoc2021.Exercises.Day06.Part1

    @initial_cycle 9

    exercise "Part 2" do
      step("Preprocess input", fn input ->
        input
        |> String.trim()
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

      step("Create list of cycles with input", fn input ->
        cycles = for _ <- 1..@initial_cycle, do: 0

        input
        |> Enum.frequencies()
        |> Enum.reduce(cycles, fn {cycle, amount}, cycles ->
          List.replace_at(cycles, cycle, amount)
        end)
      end)

      step("Simulate fish growth", Aoc2021.Exercises.Day06.GrowthRenderer, fn input ->
        days = 256

        {cycles, history} =
          for day <- 1..days, reduce: {input, []} do
            {cycles, history} ->
              new_cycles = Part1.simulate_day(cycles)
              {new_cycles, [{day, new_cycles} | history]}
          end

        %{
          population: Enum.sum(cycles),
          history: history
        }
      end)
    end
  end

  defmodule GrowthRenderer do
    @behaviour Exercise.Renderer

    @impl true
    def render(result, _meta) do
      alias VegaLite, as: Vl

      data =
        result.history
        |> Enum.map(fn {day, cycles} ->
          %{"day" => day, "population" => Enum.sum(cycles)}
        end)

      spec =
        Vl.new(width: "container", height: "500")
        |> Vl.mark(:area, tooltip: true)
        |> Vl.data_from_values(data)
        |> Vl.encode_field(:x, "day", type: :quantitative)
        |> Vl.encode_field(:y, "population", type: :quantitative)
        |> Vl.Export.to_json()

      view_data = %{
        result: result.population,
        spec: spec
      }

      {Aoc2021Web.RendererComponents.VegaLite, view_data}
    end
  end
end

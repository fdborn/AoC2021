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

      step("Simulate fish growth", fn input ->
        days = 80

        cycles =
          for _ <- 1..days, reduce: input do
            cycles -> simulate_day(cycles)
          end

        Enum.sum(cycles)
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

      step("Simulate fish growth", fn input ->
        days = 256

        cycles =
          for _ <- 1..days, reduce: input do
            cycles -> Part1.simulate_day(cycles)
          end

        Enum.sum(cycles)
      end)
    end
  end
end

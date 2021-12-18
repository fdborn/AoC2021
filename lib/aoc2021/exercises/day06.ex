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

      step("Simulate fish growth", fn input ->
        days = 80

        input
        |> Enum.map(&descendants(&1, days))
        |> Enum.sum()
      end)

      def descendants(cycle_offset, lifetime) when cycle_offset >= lifetime, do: 1

      def descendants(cycle_offset, lifetime) do
        immediate = ceil(max(lifetime - cycle_offset, 0) / @cycle)

        for descendant_generation <- 0..(immediate - 1), reduce: 1 do
          acc ->
            descendant_lifetime = lifetime - cycle_offset - descendant_generation * @cycle

            acc + descendants(@initial_cycle, descendant_lifetime)
        end
      end
    end
  end

  defmodule Part2 do
    use Exercise
    alias Aoc2021.Exercises.Day06.Part1

    exercise "Part 2" do
      step("Preprocess input", fn input ->
        input
        |> String.trim()
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

      step("Simulate fish growth", fn input ->
        days = 256

        # input
        # |> Enum.frequencies()
        # |> Enum.reduce(0, fn {offset, amount}, total ->
        #   descendants = Part1.descendants(offset, days)
        #   total + descendants * amount
        # end)

        "too slow :("
      end)
    end
  end
end

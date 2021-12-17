defmodule Aoc2021.Exercises.Day03 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise

    exercise "Part 1" do
      step "Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split("", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)
      end

      step "Count '1's in each index (and keep initial input length)", fn input ->
        counted_ones =
          Enum.reduce(input, fn (input, acc) ->
            Enum.zip(input, acc)
            |> Enum.map(fn {a, b} -> a + b end)
          end)

        initial_size = length(input)

        {counted_ones, initial_size}
      end

      step "Calculate gamma & epsilon rate", fn {input, initial_size} ->
        gamma =
          Enum.map(input, fn input ->
            if input > initial_size / 2, do: 1, else: 0
          end)

        epsilon =
          Enum.map(gamma, fn bit -> if bit == 1, do: 0, else: 1 end)

        {gamma, epsilon}
      end

      step "Convert to base 10 integer and multiply", fn {gamma, epsilon} ->
        gamma =
          gamma
          |> Enum.join()
          |> String.to_integer(2)

        epsilon =
          epsilon
          |> Enum.join()
          |> String.to_integer(2)

        gamma * epsilon
      end
    end
  end

  defmodule Part2 do
    use Exercise

    exercise "Part 2" do
      step "Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split("", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)
      end

      defp count_ones(input) do
        Enum.reduce(input, fn (input, acc) ->
          Enum.zip(input, acc)
          |> Enum.map(fn {a, b} -> a + b end)
        end)
      end

      defp find_by_criteria(input, criteria), do: do_find_by_criteria(input, criteria, 0)

      defp do_find_by_criteria([input], _criteria, _step), do: input
      defp do_find_by_criteria(input, criteria, step) do
        counted_ones = count_ones(input)
        input_length = length(input)

        input
        |> Enum.filter(fn line ->
          input_bit = Enum.at(line, step)
          counted_ones_bit = Enum.at(counted_ones, step)
          searched_bit = criteria.(counted_ones_bit, input_length / 2)

          input_bit == searched_bit
        end)
        |> do_find_by_criteria(criteria, step + 1)
      end


      step "Calculate oxygen generator- and CO2 scrubber rating", fn input ->
        oxygen_rating_criteria = fn
          ones, half when ones == half -> 1
          ones, half when ones > half -> 1
          ones, half when ones < half -> 0
        end

        scrubber_rating_criteria = fn
          ones, half when ones == half -> 0
          ones, half when ones > half -> 0
          ones, half when ones < half -> 1
        end

        oxygen_rating = find_by_criteria(input, oxygen_rating_criteria)
        scrubber_rating = find_by_criteria(input, scrubber_rating_criteria)

        {oxygen_rating, scrubber_rating}
      end

      step "Convert to base 10 integer and multiply", fn {oxygen_rating, scrubber_rating} ->
        oxygen_rating =
          oxygen_rating
          |> Enum.join()
          |> String.to_integer(2)

        scrubber_rating =
          scrubber_rating
          |> Enum.join()
          |> String.to_integer(2)

        oxygen_rating * scrubber_rating
      end
    end
  end
end

defmodule Aoc2021.Exercises.Day08 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise
    alias Aoc2021.Exercises.Day08.Solver

    exercise "Part 1" do
      defp process_signals(input) do
        input
        |> String.split(" ", trim: true)
        |> Enum.map(fn signal ->
          signal
          |> String.graphemes()
          |> Enum.map(&String.to_atom/1)
        end)
      end

      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn entry ->
          [patterns, outputs] = String.split(entry, "|")

          patterns = process_signals(patterns)
          outputs = process_signals(outputs)

          %{
            patterns: patterns,
            outputs: outputs
          }
        end)
      end)

      def format_pattern(pattern) do
        bool_pattern = for _ <- 1..7, do: false

        pattern
        |> Enum.reduce(bool_pattern, fn
          :a, acc -> List.replace_at(acc, 0, true)
          :b, acc -> List.replace_at(acc, 1, true)
          :c, acc -> List.replace_at(acc, 2, true)
          :d, acc -> List.replace_at(acc, 3, true)
          :e, acc -> List.replace_at(acc, 4, true)
          :f, acc -> List.replace_at(acc, 5, true)
          :g, acc -> List.replace_at(acc, 6, true)
        end)
      end

      step("Format patterns to boolean patterns", fn input ->
        input
        |> Enum.map(fn entry ->
          patterns =
            entry.patterns
            |> Enum.map(&format_pattern/1)

          %{entry | patterns: patterns}
        end)
      end)

      def fields(), do: [:a, :b, :c, :d, :e, :f, :g]

      def rules(),
        do: %{
          0 => &(&1.a and &1.b and &1.c and &1.e and &1.f and &1.g and not &1.d),
          1 => &(&1.c and &1.f and not (&1.a or &1.b or &1.d or &1.e or &1.g)),
          2 => &(&1.a and &1.c and &1.d and &1.e and &1.g and not (&1.b or &1.f)),
          3 => &(&1.a and &1.c and &1.d and &1.f and &1.g and not (&1.b or &1.e)),
          4 => &(&1.b and &1.c and &1.d and &1.f and not (&1.a or &1.e or &1.g)),
          5 => &(&1.a and &1.b and &1.d and &1.f and &1.g and not (&1.c or &1.e)),
          6 => &(&1.a and &1.b and &1.d and &1.e and &1.f and &1.g and not &1.c),
          7 => &(&1.a and &1.c and &1.f and not (&1.b or &1.d or &1.e or &1.g)),
          8 => &(&1.a and &1.b and &1.c and &1.d and &1.e and &1.f and &1.g),
          9 => &(&1.a and &1.b and &1.c and &1.d and &1.f and &1.g and not &1.e)
        }

      step("Solve patterns", fn input ->
        solver = Solver.new(fields(), rules())

        input
        |> Enum.map(fn entry ->
          input_values =
            entry.patterns
            |> Enum.map(fn pattern ->
              fields()
              |> Enum.zip(pattern)
              |> Enum.into(%{})
            end)

          {:solved, solution} = Solver.solve(solver, input_values)

          %{
            outputs: entry.outputs,
            solution: solution
          }
        end)
      end)

      def decode(input), do: do_decode(Enum.sort(input))

      defp do_decode([:a, :b, :c, :e, :f, :g]), do: 0
      defp do_decode([:c, :f]), do: 1
      defp do_decode([:a, :c, :d, :e, :g]), do: 2
      defp do_decode([:a, :c, :d, :f, :g]), do: 3
      defp do_decode([:b, :c, :d, :f]), do: 4
      defp do_decode([:a, :b, :d, :f, :g]), do: 5
      defp do_decode([:a, :b, :d, :e, :f, :g]), do: 6
      defp do_decode([:a, :c, :f]), do: 7
      defp do_decode([:a, :b, :c, :d, :e, :f, :g]), do: 8
      defp do_decode([:a, :b, :c, :d, :f, :g]), do: 9

      step("Decode outputs", fn input ->
        input
        |> Enum.map(fn entry ->
          entry.outputs
          |> Enum.map(fn output ->
            output
            |> Enum.map(&Map.get(entry.solution, &1))
            |> decode()
          end)
        end)
      end)

      step("Count numbers 1, 4, 7 & 8", fn input ->
        input
        |> List.flatten()
        |> Enum.filter(&Kernel.in(&1, [1, 4, 7, 8]))
        |> length()
      end)
    end
  end

  defmodule Part2 do
    use Exercise
    alias Aoc2021.Exercises.Day08.Solver
    alias Aoc2021.Exercises.Day08.Part1

    exercise "Part 2" do
      defp process_signals(input) do
        input
        |> String.split(" ", trim: true)
        |> Enum.map(fn signal ->
          signal
          |> String.graphemes()
          |> Enum.map(&String.to_atom/1)
        end)
      end

      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn entry ->
          [patterns, outputs] = String.split(entry, "|")

          patterns = process_signals(patterns)
          outputs = process_signals(outputs)

          %{
            patterns: patterns,
            outputs: outputs
          }
        end)
      end)

      step("Format patterns to boolean patterns", fn input ->
        input
        |> Enum.map(fn entry ->
          patterns =
            entry.patterns
            |> Enum.map(&Part1.format_pattern/1)

          %{entry | patterns: patterns}
        end)
      end)

      step("Solve patterns", fn input ->
        solver = Solver.new(Part1.fields(), Part1.rules())

        input
        |> Enum.map(fn entry ->
          input_values =
            entry.patterns
            |> Enum.map(fn pattern ->
              Part1.fields()
              |> Enum.zip(pattern)
              |> Enum.into(%{})
            end)

          {:solved, solution} = Solver.solve(solver, input_values)

          %{
            outputs: entry.outputs,
            solution: solution
          }
        end)
      end)

      step("Decode outputs", fn input ->
        input
        |> Enum.map(fn entry ->
          entry.outputs
          |> Enum.map(fn output ->
            output
            |> Enum.map(&Map.get(entry.solution, &1))
            |> Part1.decode()
          end)
        end)
      end)

      step("Sum up all outputs", fn input ->
        input
        |> Enum.map(&Enum.join/1)
        |> Enum.map(&String.to_integer/1)
        |> Enum.sum()
      end)
    end
  end

  defmodule Solver do
    defstruct fields: [], rules: %{}

    def new(fields, rules) do
      %__MODULE__{
        fields: fields,
        rules: rules
      }
    end

    def solve(%__MODULE__{} = solver, inputs) do
      resolution =
        for input <- inputs, reduce: %{} do
          assign_counters ->
            permutations = input_permutations(input, solver.fields)
            resolutions = do_solve(solver.rules, permutations)

            resolutions
            |> Enum.reduce(assign_counters, fn %{assigns: assigns}, acc ->
              Map.update(acc, assigns, 1, &(&1 + 1))
            end)
        end
        |> Enum.group_by(fn {_, value} -> value end, fn {assigns, _} -> assigns end)
        |> Enum.max(fn {amount_a, _}, {amount_b, _} -> amount_a > amount_b end)

      case resolution do
        {max_hits, [assigns]} when max_hits == length(inputs) -> {:solved, assigns}
        {max_hits, assigns} -> {:unsolved, {max_hits, assigns}}
      end
    end

    defp do_solve(rules, input) do
      input
      |> Enum.map(fn input ->
        {test_input, assigns} =
          Enum.map_reduce(input, %{}, fn {key, {label, value}}, assigns ->
            assigns = Map.put(assigns, label, key)

            {{key, value}, assigns}
          end)

        hits =
          test_input
          |> Enum.into(%{})
          |> test_rules(rules)
          |> Enum.filter(fn {_, result} -> result end)

        %{
          hits: hits,
          assigns: assigns
        }
      end)
      |> Enum.filter(fn results -> length(results.hits) > 0 end)
    end

    defp test_rules(input, rules) do
      Enum.map(rules, fn {name, rule} -> {name, apply(rule, [input])} end)
    end

    defp input_permutations(input, fields) do
      permutations(Map.to_list(input))
      |> Enum.map(&Enum.zip(fields, &1))
      |> Enum.map(&Enum.into(&1, %{}))
    end

    defp permutations([]), do: [[]]

    defp permutations(list) do
      for element <- list, tail <- permutations(list -- [element]), do: [element | tail]
    end
  end
end

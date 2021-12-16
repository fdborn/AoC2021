defmodule Aoc2021.Exercises.Day02 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise

    exercise "Part 1" do
      step "Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn
          "forward " <> units -> {:forward, String.to_integer(units)}
          "down " <> units -> {:down, String.to_integer(units)}
          "up " <> units -> {:up, String.to_integer(units)}
        end)
      end

      step "Add start position", fn input ->
        {{0, 0}, input}
      end

      step "Follow directions", Aoc2021.Exercises.Day02.MovementRenderer, fn {start, input} ->
        {intermediate, end_pos} =
          Enum.map_reduce(input, start, fn
            {:forward, units}, {pos, depth} -> {{pos + units, depth}, {pos + units, depth}}
            {:down, units}, {pos, depth} -> {{pos, depth + units}, {pos, depth + units}}
            {:up, units}, {pos, depth} -> {{pos, depth - units}, {pos, depth - units}}
          end)

        with_meta end_pos, intermediate: intermediate
      end

      step "Multiply positions", fn {pos, depth} ->
        pos * depth
      end
    end
  end

  defmodule MovementRenderer do
    @behaviour Aoc2021.Exercise.Renderer

    @impl true
    def render(result, meta) do
      alias VegaLite, as: Vl

      data = for {x, y} <- meta[:intermediate], do: %{"distance" => x, "depth" => y * -1}

      spec =
        Vl.new(width: "container", height: "500")
        |> Vl.data_from_values(data)
        |> Vl.mark(:line, tooltip: true, point: true)
        |> Vl.encode_field(:x, "distance", type: :quantitative)
        |> Vl.encode_field(:y, "depth", type: :quantitative)
        |> Vl.param("grid", select: [type: :interval], bind: "scales")
        |> Vl.Export.to_json()

      view_data = %{
        result: result,
        spec: spec,
      }

      {Aoc2021Web.RendererComponents.VegaLite, view_data}
    end
  end

end

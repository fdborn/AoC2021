defmodule Aoc2021.Exercises.Day05 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise
    alias Aoc2021.Exercises.Day05.Board

    exercise "Part 1" do
      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split(" -> ")
          |> Enum.map(fn coordinate ->
            coordinate
            |> String.split(",")
            |> Enum.map(&String.to_integer/1)
            |> List.to_tuple()
          end)
        end)
      end)

      step("Filter diagonal lines", fn input ->
        Enum.filter(input, fn [{x1, y1}, {x2, y2}] ->
          x1 == x2 || y1 == y2
        end)
      end)

      step("Get maximum values of coordinates", fn input ->
        {max_coords_x, max_coords_y} =
          input
          |> Enum.map(&Enum.unzip/1)
          |> Enum.map(fn {coords_x, coords_y} ->
            max_x = Enum.max(coords_x)
            max_y = Enum.max(coords_y)

            {max_x, max_y}
          end)
          |> Enum.unzip()

        %{
          max_x: Enum.max(max_coords_x),
          max_y: Enum.max(max_coords_y),
          coordinates: input
        }
      end)

      step("Build board", Aoc2021.Exercises.Day05.BoardRenderer, fn input ->
        board = Board.new(input.max_x + 1, input.max_y + 1)

        %{
          board: board,
          coordinates: input.coordinates
        }
      end)

      step("Draw lines into board", Aoc2021.Exercises.Day05.BoardRenderer, fn input ->
        board =
          input.coordinates
          |> Enum.reduce(input.board, fn [point1, point2], board ->
            Board.draw_line(board, point1, point2)
          end)

        %{board: board}
      end)

      step("Count all points with at least two vents", fn input ->
        input.board.cells
        |> Enum.filter(fn {_, value} -> value >= 2 end)
        |> Enum.count()
      end)
    end
  end

  defmodule Part2 do
    use Exercise
    alias Aoc2021.Exercises.Day05.Board

    exercise "Part 2" do
      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split(" -> ")
          |> Enum.map(fn coordinate ->
            coordinate
            |> String.split(",")
            |> Enum.map(&String.to_integer/1)
            |> List.to_tuple()
          end)
        end)
      end)

      step("Get maximum values of coordinates", fn input ->
        {max_coords_x, max_coords_y} =
          input
          |> Enum.map(&Enum.unzip/1)
          |> Enum.map(fn {coords_x, coords_y} ->
            max_x = Enum.max(coords_x)
            max_y = Enum.max(coords_y)

            {max_x, max_y}
          end)
          |> Enum.unzip()

        %{
          max_x: Enum.max(max_coords_x),
          max_y: Enum.max(max_coords_y),
          coordinates: input
        }
      end)

      step("Build board", Aoc2021.Exercises.Day05.BoardRenderer, fn input ->
        board = Board.new(input.max_x + 1, input.max_y + 1)

        %{
          board: board,
          coordinates: input.coordinates
        }
      end)

      step("Draw lines into board", Aoc2021.Exercises.Day05.BoardRenderer, fn input ->
        board =
          input.coordinates
          |> Enum.reduce(input.board, fn [point1, point2], board ->
            Board.draw_line(board, point1, point2)
          end)

        %{board: board}
      end)

      step("Count all points with at least two vents", fn input ->
        input.board.cells
        |> Enum.filter(fn {_, value} -> value >= 2 end)
        |> Enum.count()
      end)
    end
  end

  defmodule Board do
    defstruct cells: %{}, width: nil, height: nil

    def new(width, height) do
      %__MODULE__{
        cells: %{},
        width: width,
        height: height
      }
    end

    def draw_line(%__MODULE__{} = board, point1, point2) do
      lerp_2d(point1, point2)
      |> Enum.reduce(board, fn point, board ->
        update(board, point, &(&1 + 1))
      end)
    end

    def get(%__MODULE__{cells: cells}, point),
      do: Map.get(cells, point, 0)

    def put(%__MODULE__{cells: cells} = board, point, value),
      do: %{board | cells: Map.put(cells, point, value)}

    def update(%__MODULE__{} = board, point, fun) do
      new_value = fun.(get(board, point))

      put(board, point, new_value)
    end

    defp naive_distance({x1, y1}, {x2, y2}) do
      cond do
        x1 == x2 -> abs(y2 - y1)
        y1 == y2 -> abs(x2 - x1)
        true -> abs(x2 - x1)
      end
    end

    defp lerp_2d({x1, y1} = point1, {x2, y2} = point2) do
      distance = naive_distance(point1, point2) + 1

      interp_vector =
        (
          x =
            case x2 - x1 do
              x when x > 0 -> 1
              x when x < 0 -> -1
              _ -> 0
            end

          y =
            case y2 - y1 do
              y when y > 0 -> 1
              y when y < 0 -> -1
              _ -> 0
            end

          {x, y}
        )

      for step <- 0..(distance - 1), do: apply_vector(point1, interp_vector, step)
    end

    def apply_vector({x, y}, {vector_x, vector_y}, times),
      do: {x + vector_x * times, y + vector_y * times}
  end

  defmodule BoardRenderer do
    @behaviour Exercise.Renderer

    @impl true
    def render(result, _meta) do
      alias VegaLite, as: Vl

      {board, result} = Map.pop!(result, :board)

      data =
        board.cells
        |> Enum.map(fn {{x, y}, value} ->
          %{
            "x" => x,
            "y" => y,
            "value" => value
          }
        end)

      spec =
        Vl.new(width: "500", height: "500")
        |> Vl.mark(:rect)
        |> Vl.data_from_values(data)
        |> Vl.encode_field(:x, "x",
          type: :quantitative,
          sort: :ascending,
          bin: [maxbins: 100, minstep: 1]
        )
        |> Vl.encode_field(:y, "y",
          type: :quantitative,
          sort: :descending,
          bin: [maxbins: 100, minstep: 1]
        )
        |> Vl.encode_field(:color, "value", type: :quantitative, title: "Vents")
        |> Vl.Export.to_json()

      view_data = %{
        result: result,
        spec: spec
      }

      {Aoc2021Web.RendererComponents.VegaLite, view_data}
    end
  end
end

defmodule Aoc2021.Exercises.Day04 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise

    exercise "Part 1" do
      step "Preprocess input", fn input ->
        [numbers | boards] =
          input
          |> String.split("\n")

        %{
          numbers: numbers,
          boards: boards,
        }
      end

      step "Clean up data", fn input ->
        board_chunk_fun = fn line, acc ->
          if line == "" do
            {:cont, Enum.reverse(acc), []}
          else
            {:cont, [line | acc]}
          end
        end

        board_after_fun = fn acc ->
          {:cont, Enum.reverse(acc), acc}
        end

        boards =
          input.boards
          |> Enum.chunk_while([], board_chunk_fun, board_after_fun)
          |> Enum.filter(&(!Enum.empty?(&1)))
          |> Enum.map(fn board ->
            Enum.map(board, fn line ->
              line
              |> String.split(" ", trim: true)
              |> Enum.map(&String.to_integer/1)
            end)
          end)

        numbers =
          input.numbers
            |> String.split(",", trim: true)
            |> Enum.map(&String.to_integer/1)

          %{
            boards: boards,
            numbers: numbers,
          }
      end

      def bingo_in_rows?(board) do
        Enum.any?(board, fn row ->
          Enum.all?(row, &(Kernel.match?({:marked, _}, &1)))
        end)
      end

      def bingo?(board) do
        if bingo_in_rows?(board) do
          true
        else
          transposed_board =
            board
            |> Enum.zip()
            |> Enum.map(&Tuple.to_list/1)

          bingo_in_rows?(transposed_board)
        end
      end

      def mark_number(board, number) do
        {board, _} =
          Enum.map_reduce(board, false, fn
            row, false ->
              number_index =
                Enum.find_index(row, fn
                  {:marked, field} -> field == number
                  field -> field == number
                end)

              if number_index do
                row = List.update_at(row, number_index, fn number -> {:marked, number} end)
                {row, true}
              else
                {row, false}
              end

            row, true ->
              {row, true}
          end)

        board
      end

      step "Play bingo!", fn %{boards: boards, numbers: numbers} ->
        {bingo_board, number} =
          Enum.reduce_while(numbers, boards, fn number, boards ->
            marked_boards =
              Enum.map(boards, &mark_number(&1, number))

            bingos = Enum.map(marked_boards, &bingo?/1)

            if Enum.any?(bingos) do
              bingo_board =
                marked_boards
                |> Enum.zip(bingos)
                |> Enum.filter(&match?({_, true}, &1))
                |> hd()
                |> elem(0)

              {:halt, {bingo_board, number}}
            else
              {:cont, marked_boards}
            end
          end)

        %{
          board: bingo_board,
          number: number,
        }
      end

      step "Calculate score", fn input ->
        unmarked_sum =
          input.board
          |> Enum.reduce(0, fn row, sum ->
            row_sum =
              Enum.filter(row, &!match?({:marked, _}, &1))
              |> Enum.sum()

            sum + row_sum
          end)

        unmarked_sum * input.number
      end
    end
  end

  defmodule Part2 do
    use Exercise
    alias Aoc2021.Exercises.Day04.Part1

    exercise "Part2" do
      step "Preprocess input", fn input ->
        [numbers | boards] =
          input
          |> String.split("\n")

        %{
          numbers: numbers,
          boards: boards,
        }
      end

      step "Clean up data", fn input ->
        board_chunk_fun = fn line, acc ->
          if line == "" do
            {:cont, Enum.reverse(acc), []}
          else
            {:cont, [line | acc]}
          end
        end

        board_after_fun = fn acc ->
          {:cont, Enum.reverse(acc), acc}
        end

        boards =
          input.boards
          |> Enum.chunk_while([], board_chunk_fun, board_after_fun)
          |> Enum.filter(&(!Enum.empty?(&1)))
          |> Enum.map(fn board ->
            Enum.map(board, fn line ->
              line
              |> String.split(" ", trim: true)
              |> Enum.map(&String.to_integer/1)
            end)
          end)

        numbers =
          input.numbers
            |> String.split(",", trim: true)
            |> Enum.map(&String.to_integer/1)

          %{
            boards: boards,
            numbers: numbers,
          }
      end

      step "Play bingo!", fn %{boards: boards, numbers: numbers} ->
        {last_bingo_board, number} =
          Enum.reduce_while(numbers, boards, fn number, boards ->
            marked_boards = Enum.map(boards, &Part1.mark_number(&1, number))
            bingos = Enum.map(marked_boards, &Part1.bingo?/1)

            if Enum.any?(bingos) do
              if length(marked_boards) == 1 do
                {:halt, {hd(marked_boards), number}}
              else
                {no_bingo_boards, _} =
                  marked_boards
                  |> Enum.zip(bingos)
                  |> Enum.filter(&!match?({_, true}, &1))
                  |> Enum.unzip()

                {:cont, no_bingo_boards}
              end
            else
              {:cont, marked_boards}
            end
          end)

        %{
          board: last_bingo_board,
          number: number,
        }
      end

      step "Calculate score", fn input ->
        unmarked_sum =
          input.board
          |> Enum.reduce(0, fn row, sum ->
            row_sum =
              Enum.filter(row, &!match?({:marked, _}, &1))
              |> Enum.sum()

            sum + row_sum
          end)

        unmarked_sum * input.number
      end
    end
  end
end

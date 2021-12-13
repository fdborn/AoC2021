defmodule Aoc2021.Exercise.Renderer.Text do
  @behaviour Aoc2021.Exercise.Renderer

  @impl true
  def render_input(input) do
    """
    #{big_line()}
    Input:
    #{small_line()}
    #{inspect(input, pretty: true, charlists: :as_lists)}
    #{big_line()}
    """
  end

  @impl true
  def render_step(result, meta) do
    elapsed =
      Timex.Duration.from_microseconds(meta[:elapsed])
      |> Timex.Format.Duration.Formatters.Humanized.format()

    ~s"""
                                |
                                |
                                v
    #{big_line()}
    Step #{meta[:step]}: #{meta[:description]}
    #{small_line()}
    Result: (took #{elapsed})
    #{small_line()}
    #{inspect(result, pretty: true, charlists: :as_lists)}
    #{big_line()}
    """
  end

  defp big_line(), do: "=========================================================="
  defp small_line(), do: "----------------------------------------------------------"
end

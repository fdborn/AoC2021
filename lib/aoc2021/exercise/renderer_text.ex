defmodule Aoc2021.Exercise.Renderer.Text do
  @behaviour Aoc2021.Exercise.Renderer

  @impl true
  def render(input, meta) do
    if meta[:is_input] do
      render_input(input)
    else
      render_step(input, meta)
    end
  end

  defp render_input(input) do
    """
    #{big_line()}
    Input:
    #{small_line()}
    #{inspect(input, pretty: true, charlists: :as_lists)}
    #{big_line()}
    """
  end

  defp render_step(result, meta) do
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

  defp big_line(),
    do: "================================================================================"

  defp small_line(),
    do: "--------------------------------------------------------------------------------"
end

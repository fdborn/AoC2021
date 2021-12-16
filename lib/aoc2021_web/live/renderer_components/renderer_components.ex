defmodule Aoc2021Web.RendererComponents do
  use Phoenix.Component

  def default(assigns) do
    elapsed =
      Timex.Duration.from_microseconds(assigns.meta[:elapsed])
      |> Timex.Format.Duration.Formatters.Humanized.format()

    assigns =
      assigns
      |> assign(:elapsed, elapsed)

    ~H"""
    <div>
      <div class="exercise-result-meta">Took: <%= @elapsed %></div>
    </div>
    """
  end
end

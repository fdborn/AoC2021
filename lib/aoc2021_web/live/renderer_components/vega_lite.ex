defmodule Aoc2021Web.RendererComponents.VegaLite do
  use Aoc2021Web, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div id={System.unique_integer([:positive])} class="vega-lite" phx-hook="VegaLiteDisplay">
        <script class="vega-lite-spec" type="application/json">
          <%= raw @meta[:spec] %>
        </script>
      </div>
      <div class="exercise-result-headline">Output:</div>
      <pre><%= inspect(@meta[:result], pretty: true, charlists: :as_lists) %></pre>
    </div>
    """
  end
end

defmodule Aoc2021Web.RendererComponents.Default do
  use Aoc2021Web, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <pre><%= inspect(@meta[:result], pretty: true, charlists: :as_lists) %></pre>
    """
  end

end

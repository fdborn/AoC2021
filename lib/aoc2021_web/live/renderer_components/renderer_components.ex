defmodule Aoc2021Web.RendererComponents do
  use Phoenix.Component

  def plaintext(assigns) do
    ~H"<pre><%= assigns.text %></pre>"
  end
end

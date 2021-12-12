defmodule Aoc2021Web.PageController do
  use Aoc2021Web, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end

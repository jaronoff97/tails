defmodule TailsWeb.PageController do
  use TailsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

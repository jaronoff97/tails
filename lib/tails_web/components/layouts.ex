defmodule TailsWeb.Layouts do
  use TailsWeb, :html

  embed_templates "layouts/*"

  def toggle_navbar_menu(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#menu", in: "fade-in-scale", out: "fade-out-scale")
  end
end

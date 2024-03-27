defmodule TailsWeb.Otel.DataViewer do
  alias TailsWeb.Otel.Attributes
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <h1>Data</h1>
    <%= if length(Map.keys(@data)) > 0 do %>
      <Attributes.show id="attribute-popup" data={@data["attributes"]} />
      <Attributes.show id="resource-popup" data={@data["resource"]} />
      <%= Jason.encode!(@data) %>
    <% end %>
    """
  end
end

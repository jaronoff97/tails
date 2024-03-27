defmodule TailsWeb.Otel.DataViewer do
  alias TailsWeb.Otel.Attributes
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <h1>Data</h1>
    <%= if length(Map.keys(@data)) > 0 do %>
      <Attributes.show data={@data["attributes"]} modal_type={@modal_type} />
      <Attributes.show data={@data["resource"]} modal_type={@modal_type} />
      <%= Jason.encode!(@data) %>
    <% end %>
    """
  end
end

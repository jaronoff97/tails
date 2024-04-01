defmodule TailsWeb.Otel.DataViewer do
  alias TailsWeb.Otel.Attributes
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <h1>Data</h1>
    <%= if length(Map.keys(@data)) > 0 do %>
      <Attributes.show id="attribute-popup" data={@data["attributes"]} />
      <Attributes.show id="resource-popup" data={@data["resource"]} />
      <div class="relative mt-6 flex-1 px-4 sm:px-6">
        <div id="data-viewer" phx-update="ignore"></div>
        <textarea id="data_viewer" phx-hook="DataViewer" class="hidden">
        <%= Jason.encode!(@data, [{:pretty, true}]) %>
        </textarea>
      </div>
    <% end %>
    """
  end
end

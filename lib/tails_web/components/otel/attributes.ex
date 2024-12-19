defmodule TailsWeb.Otel.Attributes do
  use Phoenix.Component
  import TailsWeb.CoreComponents
  alias Tails.Telemetry

  def show(assigns) do
    if assigns[:data] == nil do
      ~H"""
      <div>
        <.table id={@id} rows={[]} caption={@caption}>
          <:col :let={attribute} label="key"><%= attribute["key"] %></:col>
          <:col :let={attribute} label="value">
            <%= Telemetry.string_from_value(attribute["value"]) %>
          </:col>
        </.table>
      </div>
      """
    else
      ~H"""
      <div>
        <.table id={@id} rows={@data} caption={@caption}>
          <:col :let={attribute} label="key"><%= attribute["key"] %></:col>
          <:col :let={attribute} label="value">
            <%= Telemetry.string_from_value(attribute["value"]) %>
          </:col>
        </.table>
      </div>
      """
    end
  end
end

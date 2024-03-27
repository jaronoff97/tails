defmodule TailsWeb.Otel.ResourceData do
  alias TailsWeb.Otel.{Metric, Span, Log}
  use Phoenix.Component
  alias Tails.Telemetry

  def show(assigns) do
    ~H"""
    <%= case @stream_name do %>
      <% :metrics -> %>
        <Metric.show metric={@data} row_click={@row_click} />
      <% :spans -> %>
        <Span.show span={@data} row_click={@row_click} />
      <% :logs -> %>
        <Log.show log={@data} row_click={@row_click} />
      <% _ -> %>
    <% end %>
    <td
      :for={col_name <- @custom_columns}
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@data)}
    >
      <%= get_attribute_value(@data, "attributes", col_name) %>
    </td>
    <td
      :for={col_name <- @resource_columns}
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@data)}
    >
      <%= get_attribute_value(@data, "resource", col_name) %>
    </td>
    """
  end

  def get_attribute_value(data, accessor, key) do
    IO.inspect(data)

    data[accessor]
    |> Enum.find(%{}, fn attribute -> attribute["key"] == key end)
    |> Map.get("value")
    |> Telemetry.string_from_value()
  end
end

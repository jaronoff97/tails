defmodule TailsWeb.Otel.ResourceData do
  alias TailsWeb.Otel.{Metric, Span, Log}
  use Phoenix.Component
  alias Tails.Telemetry

  def show(assigns) do
    ~H"""
    <%= case @stream_name do %>
      <% :metrics -> %>
        <Metric.show metric={@data} />
      <% :spans -> %>
        <Span.show span={@data} />
      <% :logs -> %>
        <Log.show log={@data} />
      <% _ -> %>
    <% end %>
    <td :for={col_name <- @custom_columns}>
      <%= get_attribute_value(@data, col_name) %>
    </td>
    <td>
      <button
        class="py-2.5 px-5 me-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-full border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-100 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
        phx-click={@attribute_click && @attribute_click.(@data)}
      >
        Show attributes
      </button>
    </td>

    <td>
      <button
        class="py-2.5 px-5 me-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-full border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-100 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
        phx-click={@resource_attribute_click && @resource_attribute_click.(@data)}
      >
        Show Resource attributes
      </button>
    </td>
    """
  end

  def get_attribute_value(data, key) do
    data["attributes"]
    |> Enum.find(%{}, fn attribute -> attribute["key"] == key end)
    |> Map.get("value")
    |> Telemetry.string_from_value()
  end
end

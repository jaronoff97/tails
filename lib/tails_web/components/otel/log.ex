defmodule TailsWeb.Otel.Log do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@log)}
    >
      <%= @log["timeUnixNano"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@log)}
    >
      <%= @log["severityText"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@log)}
    >
      <%= @log["spanId"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@log)}
    >
      <%= @log["body"] |> Jason.encode!() %>
    </td>
    """
  end
end

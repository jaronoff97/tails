defmodule TailsWeb.Otel.Span do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["traceId"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["parentSpanId"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["spanId"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["startTimeUnixNano"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["endTimeUnixNano"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["name"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= @span["kind"] %>
    </td>
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@span)}
    >
      <%= Jason.encode!(@span["status"]) %>
    </td>
    """
  end
end

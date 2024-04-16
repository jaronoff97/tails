defmodule TailsWeb.Otel.Log do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <td
      class={["relative p-0", @row_click && "hover:cursor-pointer"]}
      phx-click={@row_click && @row_click.(@log)}
    >
      <%= @log["timeUnixNano"] |> convert_to_readable %>
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

  defp convert_to_readable(nil) do
    {:ok, epoch} = Time.new(0, 0, 0)
    epoch
  end

  defp convert_to_readable(timeUnixNano) do
    {nano, _remainder} = Integer.parse(timeUnixNano, 10)

    {:ok, _date, {hour, minute, second}, {_nanos, _other}} =
      Calendar.ISO.from_unix(nano, :nanosecond)

    {:ok, converted_time} = Time.new(hour, minute, second)

    converted_time
  end
end

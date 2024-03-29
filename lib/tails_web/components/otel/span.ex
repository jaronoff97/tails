defmodule TailsWeb.Otel.Span do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <td><%= @span["traceId"] %></td>
    <td><%= @span["parentSpanId"] %></td>
    <td><%= @span["spanId"] %></td>
    <td><%= @span["startTimeUnixNano"] %></td>
    <td><%= @span["endTimeUnixNano"] %></td>
    <td><%= @span["name"] %></td>
    <td><%= @span["kind"] %></td>
    <td><%= Jason.encode!(@span["status"]) %></td>
    """
  end
end

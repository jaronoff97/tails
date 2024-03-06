defmodule TailsWeb.Otel.Log do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <div>
      <tr>
        <td><%= @log["timeUnixNano"] %></td>
        <td><%= @log["severityText"] %></td>
        <td><%= @log["spanId"] %></td>
        <td><%= @log["body"] |> Jason.encode!() %></td>
        <td><%= @log["attributes"] |> Jason.encode!() %></td>
      </tr>
    </div>
    """
  end
end

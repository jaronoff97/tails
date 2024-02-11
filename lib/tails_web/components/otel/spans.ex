defmodule TailsWeb.Otel.Spans do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <div :for={s <- get_spans(@span.data["resourceSpans"])}>
      <tr>
        <td><%= s["traceId"] %></td>
        <td><%= s["parentSpanId"] %></td>
        <td><%= s["spanId"] %></td>
        <td><%= s["startTimeUnixNano"] %></td>
        <td><%= s["endTimeUnixNano"] %></td>
        <td><%= s["name"] %></td>
        <td><%= s["kind"] %></td>
        <td><%= Jason.encode!(s["status"]) %></td>
        <td><%= Jason.encode!(s["attributes"]) %></td>
      </tr>
    </div>
    """
  end

  def get_spans(resourceSpans) do
    resourceSpans
    |> Enum.reduce([], fn e, acc ->
      acc ++ e["scopeSpans"]
    end)
    |> Enum.reduce([], fn e, acc ->
      acc ++ e["spans"]
    end)
  end
end

#

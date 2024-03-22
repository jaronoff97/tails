defmodule TailsWeb.Otel.ResourceData do
  alias TailsWeb.Otel.{Metric, Span, Log}
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <tr
      :for={{data, index} <- Enum.with_index(get_scope_data(@resource_data, @stream_name))}
      id={"#{@id}-#{index}"}
    >
      <%= case @stream_name do %>
        <% :metrics -> %>
          <Metric.show metric={data} />
        <% :spans -> %>
          <Span.show span={data} />
        <% :logs -> %>
          <Log.show log={data} />
        <% _ -> %>
      <% end %>
      <td>Show attributes</td>
      <%= if index == 0 do %>
        <td rowspan={length(get_scope_data(@resource_data, @stream_name))}>
          Show Resource Attributes
        </td>
      <% end %>
    </tr>
    """
  end

  defp get_scope_data(resource_data, stream_name) do
    resource_data[scope_accessor(stream_name)]
    |> Enum.reduce([], fn e, acc ->
      acc ++ e[record_accessor(stream_name)]
    end)
  end

  defp scope_accessor(stream_name), do: "scope#{String.capitalize(Atom.to_string(stream_name))}"
  defp record_accessor(:logs), do: "logRecords"
  defp record_accessor(stream_name), do: Atom.to_string(stream_name)
end

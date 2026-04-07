defmodule TailsWeb.Otel.Attributes do
  use Phoenix.Component
  import TailsWeb.CoreComponents
  alias Tails.Telemetry
  alias Tails.OpAMP.Helpers

  def show(assigns) do
    if assigns[:data] == nil do
      ~H"""
      <div>
        <.table id={@id} rows={[]} caption={@caption}>
          <:col :let={attribute} label="key"><%= attr_key(attribute) %></:col>
          <:col :let={attribute} label="value"><%= attr_value(attribute) %></:col>
        </.table>
      </div>
      """
    else
      ~H"""
      <div>
        <.table id={@id} rows={@data} caption={@caption}>
          <:col :let={attribute} label="key"><%= attr_key(attribute) %></:col>
          <:col :let={attribute} label="value"><%= attr_value(attribute) %></:col>
        </.table>
      </div>
      """
    end
  end

  # Handle Opamp.Proto.KeyValue structs
  defp attr_key(%Opamp.Proto.KeyValue{key: key}), do: key
  # Handle plain maps (from telemetry JSON data)
  defp attr_key(%{"key" => key}), do: key
  defp attr_key(_), do: ""

  # Handle Opamp.Proto.KeyValue structs
  defp attr_value(%Opamp.Proto.KeyValue{value: value}), do: Helpers.clean_any_value(value) || ""
  # Handle plain maps (from telemetry JSON data)
  defp attr_value(%{"value" => value}), do: Telemetry.string_from_value(value)
  defp attr_value(_), do: ""
end

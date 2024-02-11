defmodule TailsWeb.Otel.Resource do
  use Phoenix.Component
  import TailsWeb.CoreComponents

  def show(assigns) do
    ~H"""
    <div>
      <.table id="resource-table" rows={@data["attributes"]}>
        <:col :let={attribute} label="key"><%= attribute["key"] %></:col>
        <:col :let={attribute} label="value"><%= string_from_value(attribute["value"]) %></:col>
      </.table>
    </div>
    """
  end

  def string_from_value(%{"stringValue" => val}), do: val
  def string_from_value(%{"boolValue" => val}), do: to_string(val)
  def string_from_value(%{"intValue" => val}), do: to_string(val)
  def string_from_value(%{"doubleValue" => val}), do: to_string(val)
  def string_from_value(%{"bytesValue" => val}), do: to_string(val)
  def string_from_value(%{"arrayValue" => val}), do: Jason.encode!(val)
  def string_from_value(%{"kvlistValue" => val}), do: Jason.encode!(val)
  def string_from_value(_other), do: ""
end

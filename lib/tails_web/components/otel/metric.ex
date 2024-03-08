defmodule TailsWeb.Otel.Metric do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <div>
      <tr>
        <td><%= @metric |> get_data |> get_latest %></td>
        <td><%= @metric["name"] %></td>
        <td><%= @metric["description"] %></td>
        <td><%= @metric |> get_data |> get_attributes |> Jason.encode!() %></td>
      </tr>
    </div>
    """
  end

  def get_data(%{"histogram" => %{"dataPoints" => data_points}}), do: data_points
  def get_data(%{"gauge" => %{"dataPoints" => data_points}}), do: data_points
  def get_data(%{"sum" => %{"dataPoints" => data_points}}), do: data_points
  def get_data(_data), do: nil

  defp get_attributes(nil), do: []

  defp get_attributes(data_points) do
    data_points
    |> Enum.reduce([], fn e, acc ->
      attrs = Map.get(e, "attributes", %{})
      Enum.concat(acc, attrs)
    end)
  end

  defp get_latest(nil) do
    {:ok, epoch} = Time.new(0, 0, 0)
    epoch
  end

  defp get_latest(data_points) do
    {:ok, epoch} = Time.new(0, 0, 0)

    data_points
    |> Enum.reduce(epoch, fn e, acc ->
      {nano, _remainder} = Integer.parse(e["timeUnixNano"], 10)

      {:ok, _date, {hour, minute, second}, {_nanos, _other}} =
        Calendar.ISO.from_unix(nano, :nanosecond)

      {:ok, converted_time} = Time.new(hour, minute, second)

      case Time.compare(acc, converted_time) do
        :lt -> converted_time
        :gt -> acc
        :eq -> acc
      end
    end)
  end
end

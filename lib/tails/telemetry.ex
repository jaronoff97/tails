defmodule Tails.Telemetry do
  @moduledoc """
  The Telemetry context.
  """
  alias Tails.Telemetry.Message
  @channel "tails"

  def subscribe do
    Phoenix.PubSub.subscribe(Tails.PubSub, @channel)
  end

  defp broadcast({:ok, message}, event) do
    case Phoenix.PubSub.broadcast(Tails.PubSub, @channel, {event, message}) do
      :ok ->
        {:ok, message}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def new_message(data) do
    # IO.inspect(data)
    m = %Message{data: data, id: UUID.uuid4()}
    broadcast({:ok, m}, message_event(data))
  end

  def message_event(%{"resourceSpans" => _data}), do: :spans
  def message_event(%{"resourceMetrics" => _data}), do: :metrics
  def message_event(%{"resourceLogs" => _data}), do: :logs

  def string_from_value(%{"stringValue" => val}), do: val
  def string_from_value(%{"boolValue" => val}), do: to_string(val)
  def string_from_value(%{"intValue" => val}), do: to_string(val)
  def string_from_value(%{"doubleValue" => val}), do: to_string(val)
  def string_from_value(%{"bytesValue" => val}), do: to_string(val)
  def string_from_value(%{"arrayValue" => val}), do: Jason.encode!(val)
  def string_from_value(%{"kvlistValue" => val}), do: Jason.encode!(val)
  def string_from_value(_other), do: ""
end

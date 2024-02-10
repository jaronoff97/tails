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
    Phoenix.PubSub.broadcast(Tails.PubSub, @channel, {event, message})
    {:ok, message}
  end

  def new_message(data) do
    m = %Message{data: data, id: UUID.uuid4()}
    broadcast({:ok, m}, message_event(data))
  end

  def message_event(%{"resourceSpans" => _data}), do: :spans
  def message_event(%{"resourceMetrics" => _data}), do: :metrics
  def message_event(%{"resourceLogs" => _data}), do: :logs
end

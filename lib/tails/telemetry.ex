defmodule Tails.Telemetry do
  @moduledoc """
  The Telemetry context.
  """
  alias Tails.Telemetry.Message
  @channel "tails"

  def subscribe do
    Phoenix.PubSub.subscribe(Tails.PubSub, @channel)
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(Tails.PubSub, @channel, {event, message})
    {:ok, message}
  end

  def new_message(data) do
    m = %Message{data: data, id: "test"}
    broadcast({:ok, m}, :new_message)
  end

end

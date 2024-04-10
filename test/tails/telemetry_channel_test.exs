defmodule Tails.TelemetryPubSubTest do
  alias TailsWeb.TelemetryCase
  use TailsWeb.TelemetryCase

  # setup do
  #   {:ok, _, socket} = TailsWeb.UserSocket

  #   %{socket: socket}
  # end
  #

  test "can subscribe" do
    assert :ok == Tails.Telemetry.subscribe()
  end

  test "can receive metric message" do
    assert :ok == Tails.Telemetry.subscribe()
    Tails.Telemetry.new_message(TelemetryCase.get_metric())
    assert_receive {:metrics, msg}
    assert msg != nil
  end

  test "can receive span message" do
    assert :ok == Tails.Telemetry.subscribe()
    Tails.Telemetry.new_message(TelemetryCase.get_span())
    assert_receive {:spans, msg}
    assert msg != nil
  end
end

defmodule Tails.RemoteTapClient do
  use WebSockex

  def start_link(state) do
    extra_headers = [
      {"Origin", "http://localhost"}
    ]

    url = "ws://localhost:12001"
    WebSockex.start_link(url, __MODULE__, state, insecure: true, extra_headers: extra_headers)
  end

  def handle_frame({_type, msg}, state) do
    # IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")

    case Jason.decode(msg) do
      {:ok, parsed} -> Tails.Telemetry.new_message(parsed)
      {:error, err} -> IO.puts("error: #{err}")
    end

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    # IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end
end

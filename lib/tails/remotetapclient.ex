defmodule Tails.RemoteTapClient do
  use WebSockex

  def start_link(state) do
    url = "ws://localhost:12001"
    WebSockex.start_link(url, __MODULE__, state, insecure: true)
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end

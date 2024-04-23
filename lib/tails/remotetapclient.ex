defmodule Tails.RemoteTapClient do
  use WebSockex

  def start_link(state) do
    extra_headers = [
      {"Origin", "http://localhost"}
    ]

    url = System.get_env("REMOTE_TAP_ENDPOINT") || "ws://localhost:12001"

    WebSockex.start_link(url, __MODULE__, state,
      insecure: true,
      extra_headers: extra_headers,
      handle_initial_conn_failure: true
    )
  end

  def terminate(reason, _state) do
    IO.puts("WebSockex terminating with reason: #{inspect(reason)}")

    exit(:normal)
  end

  def handle_connect(_conn, state) do
    IO.puts("Connected!")
    {:ok, state}
  end

  def handle_disconnect(%{attempt_number: attempt} = _failure_map, state) do
    IO.puts("Disconnecting, attempting to connect...")

    if attempt < 100 do
      Process.sleep(1000 * attempt)
      {:reconnect, state}
    else
      IO.puts("failed to connect, exiting.")
      {:ok, state}
    end
  end

  def handle_disconnect(_connection_status_map, state) do
    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    # IO.puts("Received Message -- Message: #{inspect(msg)}")

    case Jason.decode(msg) do
      {:ok, parsed} ->
        case Tails.Telemetry.new_message(parsed) do
          {:ok, _message} ->
            {:ok, state}

          {:error, reason} ->
            IO.puts("failed to create new message: #{inspect(reason)}")
            {:close, state}
        end

      {:error, reason} ->
        IO.puts("failed to decode message: #{inspect(reason)}")
        {:close, state}
    end
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end
end

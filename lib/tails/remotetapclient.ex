defmodule Tails.RemoteTapClient do
  use GenServer
  require Logger

  @reconnect_interval 2_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_opts) do
    url = System.get_env("REMOTE_TAP_ENDPOINT") || "ws://localhost:12001"
    uri = URI.parse(url)

    state = %{
      uri: uri,
      conn: nil,
      websocket: nil,
      ref: nil,
      status: nil
    }

    {:ok, state, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    case connect(state) do
      {:ok, state} ->
        Logger.info("RemoteTap connected to #{state.uri}")
        {:noreply, state}

      {:error, reason} ->
        Logger.warning("RemoteTap connection failed: #{inspect(reason)}, retrying...")
        Process.send_after(self(), :reconnect, @reconnect_interval)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:reconnect, state) do
    state = disconnect(state)

    case connect(state) do
      {:ok, state} ->
        Logger.info("RemoteTap reconnected to #{state.uri}")
        {:noreply, state}

      {:error, reason} ->
        Logger.warning("RemoteTap reconnect failed: #{inspect(reason)}, retrying...")
        Process.send_after(self(), :reconnect, @reconnect_interval)
        {:noreply, state}
    end
  end

  def handle_info(message, %{conn: conn} = state) when conn != nil do
    case Mint.WebSocket.stream(conn, message) do
      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)
        state = handle_responses(state, responses)
        {:noreply, state}

      {:error, conn, reason, _responses} ->
        Logger.warning("RemoteTap stream error: #{inspect(reason)}, reconnecting...")
        state = put_in(state.conn, conn)
        Process.send_after(self(), :reconnect, @reconnect_interval)
        {:noreply, state}

      :unknown ->
        {:noreply, state}
    end
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("RemoteTap terminating: #{inspect(reason)}")
    disconnect(state)
    :ok
  end

  # Connection

  defp connect(state) do
    uri = state.uri
    ws_scheme = if uri.scheme in ["wss", "https"], do: :wss, else: :ws
    http_scheme = if ws_scheme == :wss, do: :https, else: :http
    port = uri.port || if(ws_scheme == :wss, do: 443, else: 80)
    path = uri.path || "/"

    with {:ok, conn} <- Mint.HTTP.connect(http_scheme, uri.host, port, protocols: [:http1]),
         {:ok, conn, ref} <- Mint.WebSocket.upgrade(ws_scheme, conn, path, [{"origin", "http://localhost"}]) do
      {:ok, %{state | conn: conn, ref: ref}}
    end
  end

  defp disconnect(%{conn: nil} = state), do: state

  defp disconnect(%{conn: conn} = state) do
    Mint.HTTP.close(conn)
    %{state | conn: nil, websocket: nil, ref: nil}
  end

  # Response handling

  defp handle_responses(state, responses) do
    Enum.reduce(responses, state, fn
      {:status, ref, status}, state when ref == state.ref ->
        %{state | status: status}

      {:headers, ref, headers}, state when ref == state.ref ->
        case Mint.WebSocket.new(state.conn, ref, state.status, headers) do
          {:ok, conn, websocket} ->
            %{state | conn: conn, websocket: websocket}

          {:error, conn, reason} ->
            Logger.warning("RemoteTap WebSocket upgrade failed: #{inspect(reason)}")
            Process.send_after(self(), :reconnect, @reconnect_interval)
            %{state | conn: conn}
        end

      {:data, ref, data}, state when ref == state.ref and state.websocket != nil ->
        case Mint.WebSocket.decode(state.websocket, data) do
          {:ok, websocket, frames} ->
            state = %{state | websocket: websocket}
            handle_frames(state, frames)

          {:error, websocket, reason} ->
            Logger.warning("RemoteTap decode error: #{inspect(reason)}")
            %{state | websocket: websocket}
        end

      {:done, ref}, state when ref == state.ref ->
        state

      {:error, ref, reason}, state when ref == state.ref ->
        Logger.warning("RemoteTap error: #{inspect(reason)}, reconnecting...")
        Process.send_after(self(), :reconnect, @reconnect_interval)
        state

      _other, state ->
        state
    end)
  end

  defp handle_frames(state, frames) do
    Enum.reduce(frames, state, fn
      {:text, msg}, state ->
        handle_text_message(msg, state)

      {:binary, msg}, state ->
        handle_text_message(msg, state)

      {:ping, data}, state ->
        send_frame(state, {:pong, data})

      {:pong, _data}, state ->
        state

      {:close, _code, _reason}, state ->
        Logger.info("RemoteTap server closed connection, reconnecting...")
        Process.send_after(self(), :reconnect, @reconnect_interval)
        state

      _other, state ->
        state
    end)
  end

  defp handle_text_message(msg, state) do
    case Jason.decode(msg) do
      {:ok, parsed} ->
        case Tails.Telemetry.new_message(parsed) do
          {:ok, _message} -> state
          {:error, reason} ->
            Logger.warning("RemoteTap failed to process message: #{inspect(reason)}")
            state
        end

      {:error, reason} ->
        Logger.warning("RemoteTap failed to decode JSON: #{inspect(reason)}")
        state
    end
  end

  defp send_frame(%{conn: conn, websocket: websocket, ref: ref} = state, frame) do
    case Mint.WebSocket.encode(websocket, frame) do
      {:ok, websocket, data} ->
        case Mint.HTTP.stream_request_body(conn, ref, data) do
          {:ok, conn} -> %{state | conn: conn, websocket: websocket}
          {:error, conn, _reason} -> %{state | conn: conn, websocket: websocket}
        end

      {:error, websocket, _reason} ->
        %{state | websocket: websocket}
    end
  end
end

defmodule TailsWeb.AgentsChannel do
  use TailsWeb, :channel
  alias Tails.OpAMP.Server
  alias Tails.OpAMP.Helpers
  require Logger

  @impl true
  def join("agents:" <> agent_id, payload, socket) do
    case Tails.Agents.subscribe() do
      :ok -> :ok
      {:error, reason} -> Logger.warning("Failed to subscribe to agents: #{inspect(reason)}")
    end

    response = Server.update_state(payload)

    {:ok, response, assign(socket, :agent_id, agent_id)}
  end

  @impl true
  def handle_info({:request_config, _payload}, socket) do
    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: Helpers.server_capabilities(),
      flags: Helpers.server_flags_to_int(:ServerToAgentFlags_ReportFullState)
    }

    push(socket, "", server_to_agent)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:agent_updated, _payload}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:agent_disconnected, _payload}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: Helpers.server_capabilities()
    }

    {:reply, server_to_agent, socket}
  end

  @impl true
  def handle_in("heartbeat", payload, socket) do
    response = Server.update_state(payload)
    {:reply, {:ok, response}, socket}
  end

  @impl true
  def terminate(reason, socket) do
    case reason do
      {:shutdown, :timeout} ->
        Logger.info("Agent #{socket.assigns.agent_id} timed out")

      {:shutdown, :peer_closed} ->
        Logger.info("Agent #{socket.assigns.agent_id} disconnected")

      {:shutdown, :closed} ->
        Logger.info("Agent #{socket.assigns.agent_id} disconnected")

      other ->
        Logger.warning("Agent #{socket.assigns.agent_id} terminated: #{inspect(other)}")
    end

    Server.connection_terminated()
    TailsWeb.OpAMPSerializer.remove(socket.assigns.agent_id)
    {:shutdown, socket.assigns.agent_id}
  end
end

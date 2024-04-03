defmodule TailsWeb.AgentsChannel do
  import Bitwise
  use TailsWeb, :channel

  @heartbeat_interval 10_000

  @impl true
  def join("agents:" <> agent_id, payload, socket) do
    case Tails.Agents.subscribe() do
      :ok ->
        IO.puts("Subscribed to agents channel")

      {:error, reason} ->
        IO.puts("Failed to subscribe, reason: #{inspect(reason)}")
    end

    # IO.puts("joinin")
    # schedule_heartbeat(agent_id)

    server_to_agent =
      connect_to_agent(agent_id, payload)
      |> generate_response

    {:ok, server_to_agent,
     socket
     |> assign(:agent_id, agent_id)}
  end

  @impl true
  def handle_info({:request_config, _payload}, socket) do
    # IO.inspect("requesting config")

    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: server_capabilities(),
      # :ServerToAgentFlags_ReportFullState
      flags: 1
    }

    # IO.puts "------------ configmap pre-send"
    # IO.inspect(payload.remote_config_status)
    # IO.puts "------------ configmap pre-send"
    push(socket, "", server_to_agent)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:heartbeat, agent_id}, socket) do
    # IO.inspect("sending heartbeat")

    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: agent_id,
      capabilities: server_capabilities(),
      # :ServerToAgentFlags_ReportFullState
      flags: 1
    }

    push(socket, "", server_to_agent)
    schedule_heartbeat(agent_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:agent_created, _payload}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:agent_deleted, _payload}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:agent_updated, payload}, socket) do
    # BridgeAgent.put(:opampagent, socket.assigns.agent_id, payload.effective_config)
    # IO.puts "I AM SENDING AN UPDATE MESSAGE OMG"
    # IO.puts "------------ handle update"
    # IO.inspect payload
    # IO.puts "------------ handle update"
    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: server_capabilities(),
      remote_config: payload.desired_remote_config
    }

    # IO.puts "------------ configmap pre-send"
    # IO.inspect(payload.remote_config_status)
    # IO.puts "------------ configmap pre-send"
    push(socket, "", server_to_agent)
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", _payload, socket) do
    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: server_capabilities()
    }

    # IO.puts("here")
    {:reply, server_to_agent, socket}
  end

  @impl true
  def handle_in("heartbeat", payload, socket) do
    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: server_capabilities()
    }

    {:ok, _} = connect_to_agent(socket.assigns.agent_id, payload)

    {:reply, {:ok, server_to_agent}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (agents:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    :ok = broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    case reason do
      {:shutdown, :timeout} ->
        IO.puts("#{socket.assigns.agent_id} timed out")

      {:shutdown, :peer_closed} ->
        IO.puts("#{socket.assigns.agent_id} disconnected")

      {:shutdown, :closed} ->
        IO.puts("#{socket.assigns.agent_id} disconnected")

      other ->
        IO.inspect(other)
    end

    # Tails.Agents.delete_agent(socket.assigns.agent_id)
    TailsWeb.OpAMPSerializer.remove(socket.assigns.agent_id)
    {:shutdown, socket.assigns.agent_id}
  end

  def connect_to_agent(agent_id, payload) do
    Tails.Agents.create_agent(%{
      id: agent_id,
      effective_config: payload.effective_config,
      remote_config_status: payload.remote_config_status,
      component_health: payload.health,
      description: payload.agent_description
    })
  end

  defp schedule_heartbeat(agent_id) do
    Process.send_after(self(), {:heartbeat, agent_id}, @heartbeat_interval)
  end

  def generate_response({:ok, agent} = _agent) do
    %Opamp.Proto.ServerToAgent{
      instance_uid: agent.id,
      capabilities: server_capabilities()
    }
  end

  def server_capabilities do
    [
      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsStatus,
      Opamp.Proto.ServerCapabilities.ServerCapabilities_OffersRemoteConfig,
      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsEffectiveConfig,
      Opamp.Proto.ServerCapabilities.ServerCapabilities_OffersConnectionSettings,
      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsConnectionSettingsRequest
    ]
    |> Enum.map(fn c -> server_capability_to_int(c) end)
    |> Enum.reduce(fn c, acc -> bor(c, acc) end)
  end

  def server_capability_to_int(capability) do
    case capability do
      Opamp.Proto.ServerCapabilities.ServerCapabilities_Unspecified ->
        0

      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsStatus ->
        1

      Opamp.Proto.ServerCapabilities.ServerCapabilities_OffersRemoteConfig ->
        2

      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsEffectiveConfig ->
        4

      Opamp.Proto.ServerCapabilities.ServerCapabilities_OffersPackages ->
        8

      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsPackagesStatus ->
        10

      Opamp.Proto.ServerCapabilities.ServerCapabilities_OffersConnectionSettings ->
        20

      Opamp.Proto.ServerCapabilities.ServerCapabilities_AcceptsConnectionSettingsRequest ->
        40

      _ ->
        0
    end
  end
end

defmodule TailsWeb.AgentsChannel do
  import Bitwise
  use TailsWeb, :channel

  @impl true
  def join("agents:" <> agent_id, payload, socket) do
    server_to_agent = generate_response(payload)
    {:ok, server_to_agent, socket
      |> assign(:agent_id, agent_id)}
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
  def handle_info({:agent_updated, _payload}, socket) do
    # server_to_agent = %Opamp.Proto.ServerToAgent{
    #   instance_uid: socket.assigns.agent_id,
    #   capabilities: server_capabilities(),
    #   remote_config: payload.desired_remote_config
    # }
    # push(socket, "", server_to_agent)
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
    {:reply, server_to_agent, socket}
  end

  @impl true
  def handle_in("heartbeat", _payload, socket) do
    server_to_agent = %Opamp.Proto.ServerToAgent{
      instance_uid: socket.assigns.agent_id,
      capabilities: server_capabilities()
    }
    {:reply, {:ok, server_to_agent}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (agents:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    case reason do
      {:shutdown, :timeout} ->
        IO.puts "#{socket.assigns.agent_id} timed out"
      {:shutdown, :peer_closed} ->
        IO.puts "#{socket.assigns.agent_id} disconnected"
      other ->
        IO.inspect other
    end
    {:shutdown, socket.assigns.agent_id}
  end

  def generate_response({:ok, agent} = _agent) do
    %Opamp.Proto.ServerToAgent{
      instance_uid: agent.id,
      capabilities: server_capabilities()
    }
  end

  def generate_response({:error, agent} = _agent) do
    # Todo: use the error for something
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

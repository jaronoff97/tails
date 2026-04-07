defmodule Tails.OpAMP.Server do
  use GenServer
  alias Tails.OpAMP.Helpers
  require Logger

  # Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def update_state(proto) do
    GenServer.call(__MODULE__, {:update_state, proto})
  end

  def connection_terminated do
    GenServer.cast(__MODULE__, :connection_terminated)
  end

  # GenServer Callbacks

  @impl true
  def init(_) do
    {:ok,
     %{
       agent_id: nil,
       sequence_num: -1,
       capabilities: 0,
       effective_config: %Opamp.Proto.EffectiveConfig{
         config_map: %Opamp.Proto.AgentConfigMap{config_map: %{}}
       },
       health: :unknown,
       agent_description: %Opamp.Proto.AgentDescription{},
       remote_config_status: nil,
       connected: false
     }}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:update_state, proto}, _from, state) do
    instance_uid = proto.instance_uid

    {flags, new_state} =
      state
      |> Map.put(:agent_id, instance_uid)
      |> Map.put(:connected, true)
      |> get_new_state(proto)

    broadcast_agent_update(new_state)

    remote_config_response =
      if Helpers.agent_has_capability?(proto, :AgentCapabilities_AcceptsRemoteConfig),
        do: get_remote_config(new_state),
        else: nil

    response = %Opamp.Proto.ServerToAgent{
      instance_uid: instance_uid,
      capabilities: Helpers.server_capabilities(),
      flags: Helpers.server_flags_to_int(flags),
      remote_config: remote_config_response
    }

    {:reply, response, new_state}
  end

  @impl true
  def handle_cast(:connection_terminated, state) do
    Logger.info("Agent connection terminated")
    new_state = Map.put(state, :connected, false)
    Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {:agent_disconnected, new_state})
    {:noreply, new_state}
  end

  # State update logic ported from monorepo

  defp get_new_state(state, data) do
    {:ServerToAgentFlags_Unspecified, state}
    |> update_state_field(:capabilities, data)
    |> update_state_field(:effective_config, data)
    |> update_state_field(:remote_config_status, data)
    |> update_state_field(:health, data)
    |> update_state_field(:agent_description, data)
    |> update_state_field(:sequence_num, data)
  end

  defp update_state_field({flags, state}, term, %{sequence_num: new_seq_num} = data)
       when new_seq_num > state.sequence_num do
    case {has_capability(state, term), data_is_empty(state, term), data_is_empty(data, term)} do
      {true, true, true} ->
        Logger.debug("Requesting full state for empty but expected #{term}")
        {:ServerToAgentFlags_ReportFullState, state}

      {true, false, true} ->
        {flags, state}

      {true, _, false} ->
        Logger.debug("Updated state for #{term}")
        {flags, Map.put(state, term, Map.get(data, term))}

      {_, true, false} when term == :capabilities ->
        {flags, Map.put(state, term, Map.get(data, term))}

      {false, _, _} ->
        {flags, state}
    end
  end

  defp update_state_field({flags, state}, _term, _data) do
    {flags, state}
  end

  defp has_capability(_, :sequence_num), do: true

  defp has_capability(state, term) do
    Helpers.agent_has_capability?(state, term_to_capability(term))
  end

  defp term_to_capability(term) do
    case term do
      :effective_config -> :AgentCapabilities_ReportsEffectiveConfig
      :remote_config_status -> :AgentCapabilities_ReportsRemoteConfig
      :health -> :AgentCapabilities_ReportsHealth
      :agent_description -> :AgentCapabilities_ReportsStatus
      _ -> nil
    end
  end

  defp data_is_empty(data, term) do
    case Map.get(data, term) do
      nil -> true
      :unknown -> true
      [] -> true

      %Opamp.Proto.EffectiveConfig{
        config_map: %Opamp.Proto.AgentConfigMap{config_map: config}
      }
      when map_size(config) == 0 ->
        true

      %{} = map when map_size(map) == 0 -> true
      0 -> true
      _ -> false
    end
  end

  defp get_remote_config(state) do
    case state do
      %{desired_remote_config: %Opamp.Proto.AgentRemoteConfig{} = config} -> config
      _ -> nil
    end
  end

  defp broadcast_agent_update(state) do
    agent = %{
      id: uuid_to_string(state.agent_id),
      effective_config: state.effective_config,
      remote_config_status: state.remote_config_status,
      component_health: state.health,
      description: state.agent_description,
      connected: state.connected
    }

    Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {:agent_updated, agent})
  end

  defp uuid_to_string(uid) when is_binary(uid) and byte_size(uid) == 16 do
    UUID.binary_to_string!(uid)
  end

  defp uuid_to_string(uid) when is_binary(uid), do: uid
  defp uuid_to_string(_), do: nil
end

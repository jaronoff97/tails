defmodule Tails.Agents do
  @moduledoc """
  The Agents context. Manages PubSub for agent events.
  """

  alias Tails.OpAMP.Helpers

  def subscribe do
    Phoenix.PubSub.subscribe(Tails.PubSub, "agents")
  end

  def subscribe_to_agent(agent_id) do
    Phoenix.PubSub.subscribe(Tails.PubSub, "agents:" <> agent_id)
  end

  @spec request_latest_config() :: :ok | {:error, term()}
  def request_latest_config do
    Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {:request_config, %{}})
  end

  def generate_desired_remote_config(conf) do
    %Opamp.Proto.AgentRemoteConfig{
      config_hash: :crypto.hash(:md5, Opamp.Proto.AgentConfigMap.encode(conf)),
      config: conf
    }
  end

  def get_agent_state do
    Tails.OpAMP.Server.get_state()
  end

  def agent_attributes(description) when is_map(description) and map_size(description) > 0 do
    identifying =
      description
      |> Map.get(:identifying_attributes, [])
      |> Helpers.attributes_to_map(cast_string: true)

    non_identifying =
      description
      |> Map.get(:non_identifying_attributes, [])
      |> Helpers.attributes_to_map(cast_string: true)

    Map.merge(identifying, non_identifying)
  end

  def agent_attributes(_), do: %{}
end

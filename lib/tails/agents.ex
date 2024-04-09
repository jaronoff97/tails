defmodule Tails.Agents do
  @moduledoc """
  The Agents context.
  """

  def subscribe do
    Phoenix.PubSub.subscribe(Tails.PubSub, "agents")
  end

  def subscribe_to_agent(agent_id) do
    Phoenix.PubSub.subscribe(Tails.PubSub, "agents:" <> agent_id)
  end

  @spec broadcast({:ok, map}, atom) :: {:ok, map}
  defp broadcast({:ok, agent}, event) do
    :ok = Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {event, agent})
    :ok = Phoenix.PubSub.broadcast(Tails.PubSub, "agents:" <> agent.id, {event, agent})
    {:ok, agent}
  end

  @spec request_latest_config() :: :ok | {:error, term()}
  def request_latest_config,
    do: Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {:request_config, %{}})

  @doc """
  Creates a agent.

  ## Examples

      iex> create_agent(%{field: value})
      {:ok, %{}}

  """
  @spec create_agent(map) :: {:ok, map}
  def create_agent(agent) do
    agent =
      Map.update(agent, :description, %{}, fn desc ->
        Map.update(desc, :identifying_attributes, %{}, &convert_to_attrs(&1))
        |> Map.update(:non_identifying_attributes, %{}, &convert_to_attrs(&1))
      end)

    # Map.update(agent.description.identifying_attributes
    # Map.update(agent.description.non_identifying_attributes
    broadcast({:ok, agent}, :agent_created)
  end

  @doc """
  Updates a agent.

  ## Examples

      iex> update_agent(agent, %{field: new_value})
      {:ok, %Agent{}}

      iex> update_agent(agent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_agent(_agent, agent) do
    broadcast({:ok, agent}, :agent_updated)
  end

  @doc """
  Deletes a agent.

  ## Examples

      iex> delete_agent(agent)
      {:ok, %Agent{}}

      iex> delete_agent(agent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_agent(agent) do
    broadcast({:ok, agent}, :agent_deleted)
  end

  def generate_desired_remote_config(conf) do
    %Opamp.Proto.AgentRemoteConfig{
      config_hash: :crypto.hash(:md5, Opamp.Proto.AgentConfigMap.encode(conf)),
      config: conf
    }
  end

  defp convert_to_attrs(opamp_attrs) do
    Enum.reduce(opamp_attrs, [], fn kv, acc ->
      acc ++ [%{"key" => kv.key, "value" => %{"stringValue" => get_value(kv)}}]
    end)
  end

  defp get_value(nil), do: ""

  defp get_value(kv) do
    case kv.value.value do
      {:string_value, v} ->
        v

      {other, _v} ->
        IO.puts("unable to retrieve value for type #{other}")
        ""
    end
  end
end

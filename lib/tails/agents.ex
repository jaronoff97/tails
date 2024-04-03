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

  defp broadcast({:ok, agent}, event) do
    Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {event, agent})
    Phoenix.PubSub.broadcast(Tails.PubSub, "agents:" <> agent.id, {event, agent})
    {:ok, agent}
  end

<<<<<<< Updated upstream
  def get_agent(_id), do: nil

  def request_latest_config do
    # IO.puts("requesting!!!")
    Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {:request_config, %{}})
  end
=======
  def request_latest_config,
    do: Phoenix.PubSub.broadcast(Tails.PubSub, "agents", {:request_config, %{}})
>>>>>>> Stashed changes

  @doc """
  Creates a agent.

  ## Examples

      iex> create_agent(%{field: value})
      {:ok, %Agent{}}

      iex> create_agent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_agent(attrs \\ %{}) do
    broadcast({:ok, attrs}, :agent_created)
    {:ok, attrs}
  end

  @doc """
  Updates a agent.

  ## Examples

      iex> update_agent(agent, %{field: new_value})
      {:ok, %Agent{}}

      iex> update_agent(agent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_agent(_agent, attrs) do
    broadcast({:ok, attrs}, :agent_updated)
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
end

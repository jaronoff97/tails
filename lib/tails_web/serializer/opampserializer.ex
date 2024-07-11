defmodule TailsWeb.OpAMPSerializer do
  @behaviour Phoenix.Socket.Serializer
  use Agent

  alias Phoenix.Socket.Reply
  alias Phoenix.Socket.Message
  alias Phoenix.Socket.Broadcast

  def start_link(_opts) do
    Agent.start_link(fn -> MapSet.new() end, name: :connections)
  end

  def fastlane!(%Broadcast{} = msg) do
    msg = %Message{topic: msg.topic, event: msg.event, payload: msg.payload}

    {:socket_push, :binary, encode_data(msg.payload)}
  end

  def remove(instance_uid) do
    Agent.update(:connections, &MapSet.delete(&1, instance_uid))
  end

  def encode!(%Reply{} = reply) do
    # IO.puts("--------------- reply")
    # IO.inspect(reply)
    # IO.inspect(Agent.get(:connections, &MapSet.to_list(&1)))
    # IO.puts("--------------- reply")

    case reply.status do
      :error -> {:socket_push, :binary, encode_data(get_error_message(reply.payload))}
      _ -> {:socket_push, :binary, encode_data(reply.payload)}
    end
  end

  def encode!(%Message{} = msg) do
    # IO.puts("--------------- msg")
    # IO.inspect(msg)
    # IO.inspect(Agent.get(:connections, &MapSet.to_list(&1)))
    # IO.puts("--------------- msg")
    {:socket_push, :binary, encode_data(msg.payload)}
  end

  def encode_data(%{reason: _topic} = data) do
    :erlang.term_to_binary(data)
  end

  def encode_data(data) when is_map(data) and map_size(data) == 0 do
    :erlang.term_to_binary(data)
  end

  def encode_data(%Opamp.Proto.ServerToAgent{} = payload) do
    Opamp.Proto.ServerToAgent.encode(payload)
  end

  defp get_error_message(%{reason: "unmatched topic"}) do
    %Opamp.Proto.ServerToAgent{
      error_response: %Opamp.Proto.ServerErrorResponse{
        type: :ServerErrorResponseType_Unavailable,
        error_message: "Connection idled, reconnect requested"
      }
    }
  end

  defp get_error_message(%{reason: reason}) do
    %Opamp.Proto.ServerToAgent{
      error_response: %Opamp.Proto.ServerErrorResponse{
        type: :ServerErrorResponseType_Unavailable,
        error_message: reason
      }
    }
  end

  def decode!(raw_message, opts) do
    case Keyword.fetch(opts, :opcode) do
      {:ok, :text} -> decode_text(raw_message)
      {:ok, :binary} -> decode_binary(raw_message)
    end
  end

  defp decode_text(raw_message) do
    [join_ref, ref, topic, event, payload | _] = Phoenix.json_library().decode!(raw_message)

    %Message{
      topic: topic,
      event: event,
      payload: payload,
      ref: ref,
      join_ref: join_ref
    }
  end

  defp decode_binary(<<
         _header::size(8),
         data::binary
       >>) do
    proto = Opamp.Proto.AgentToServer.decode(data)
    instance_uuid = UUID.binary_to_string!(proto.instance_uid)
    # IO.puts("-----------------------")
    # IO.puts("is a memember?")
    # IO.inspect(Agent.get(:connections, &MapSet.member?(&1, proto.instance_uid)))
    # IO.inspect(Agent.get(:connections, &MapSet.to_list/1))
    # IO.puts("-----------------------")

    case Agent.get(:connections, &MapSet.member?(&1, instance_uuid)) do
      false -> respond_join(proto, instance_uuid)
      true -> respond_heartbeat(proto, instance_uuid)
    end
  end

  defp respond_join(proto, instance_uuid) do
    Agent.update(:connections, &MapSet.put(&1, instance_uuid))
    IO.puts("JOINING")

    %Message{
      topic: "agents:" <> instance_uuid,
      event: "phx_join",
      payload: proto,
      ref: proto.sequence_num,
      join_ref: "join"
    }
  end

  defp respond_heartbeat(proto, instance_uuid) when proto.sequence_num > 0 do
    %Message{
      topic: "agents:" <> instance_uuid,
      event: "heartbeat",
      payload: proto,
      ref: proto.sequence_num,
      join_ref: "beat"
    }
  end
end

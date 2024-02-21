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
    # IO.puts "--------------- reply"
    # IO.inspect reply
    # IO.inspect Agent.get(:connections, &MapSet.to_list(&1))
    # IO.puts "--------------- reply"
    {:socket_push, :binary, encode_data(reply.payload)}
  end

  def encode!(%Message{} = msg) do
    # IO.puts "--------------- msg"
    # IO.inspect msg
    # IO.inspect Agent.get(:connections, &MapSet.to_list(&1))
    # IO.puts "--------------- msg"
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
    # IO.puts "-----------------------"
    # IO.puts "is a memember?"
    # IO.inspect Agent.get(:connections, &MapSet.member?(&1, proto.instance_uid))
    # IO.inspect Agent.get(:connections, &MapSet.to_list/1)
    # IO.puts "-----------------------"
    case Agent.get(:connections, &MapSet.member?(&1, proto.instance_uid)) do
      false -> respond_join(proto)
      true -> respond_heartbeat(proto)
    end
  end

  defp respond_join(proto) do
    Agent.update(:connections, &MapSet.put(&1, proto.instance_uid))
    IO.puts("JOINING")

    %Message{
      topic: "agents:" <> proto.instance_uid,
      event: "phx_join",
      payload: proto,
      ref: proto.sequence_num,
      join_ref: "join"
    }
  end

  defp respond_heartbeat(proto) when proto.sequence_num > 0 do
    %Message{
      topic: "agents:" <> proto.instance_uid,
      event: "heartbeat",
      payload: proto,
      ref: proto.sequence_num,
      join_ref: "beat"
    }
  end
end

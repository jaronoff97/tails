defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.{Telemetry, Agents, Filters}

  @stream_limit 1000

  @columns %{
    metrics: ["timeUnixNano", "Name", "Description"],
    spans: [
      "StartTimeUnixNano",
      "EndTimeUnixNano",
      "TraceId",
      "ParentSpanId",
      "SpanId",
      "Name",
      "Kind",
      "Status"
    ],
    logs: ["timeUnixNano", "severityText", "spanId", "body"]
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = Telemetry.subscribe()
      :ok = Agents.subscribe()
    end

    {:ok,
     socket
     |> assign(:columns, @columns)
     |> assign(:custom_columns, MapSet.new())
     |> assign(:resource_columns, MapSet.new())
     |> assign(:available_filters, %{})
     |> assign(:available_resource_filters, %{})
     |> assign(:filters, %{})
     |> assign(:resource_filters, %{})
     |> assign(:remote_tap_started, false)
     |> assign(:should_stream, true)
     |> assign(:active_stream, :spans)
     |> assign(:page_title, "Tails")}
  end

  # Events from React via pushEvent

  @impl true
  def handle_event("change_stream", %{"value" => value}, socket) do
    stream = String.to_existing_atom(String.downcase(value))

    {:noreply,
     socket
     |> assign(:active_stream, stream)
     |> push_state_update()
     |> push_event("reset_records", %{})}
  end

  @impl true
  def handle_event("toggle_stream", _params, socket) do
    {:noreply,
     socket
     |> assign(:should_stream, !socket.assigns.should_stream)
     |> push_state_update()}
  end

  @impl true
  def handle_event("toggle_remote_tap", _params, socket) do
    case toggle_remote_tap(socket) do
      {:ok, socket} -> {:noreply, push_state_update(socket)}
      {:error, socket} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("request_config", _params, socket) do
    if !Map.has_key?(socket.assigns, :agent) or socket.assigns[:agent] == %{} do
      Agents.request_latest_config()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_columns", %{"column_type" => ct, "key" => key}, socket) do
    col_type = column_from_string(ct)

    {:noreply,
     socket
     |> assign(col_type, MapSet.put(socket.assigns[col_type], key))
     |> push_state_update()
     |> push_event("reset_records", %{})}
  end

  @impl true
  def handle_event("remove_column", %{"column" => col, "column_type" => ct}, socket) do
    col_type = column_from_string(ct)

    {:noreply,
     socket
     |> assign(col_type, MapSet.delete(socket.assigns[col_type], col))
     |> push_state_update()
     |> push_event("reset_records", %{})}
  end

  @impl true
  def handle_event(
        "update_filters",
        %{"action" => action, "filter_type" => ft, "key" => key, "val" => val},
        socket
      ) do
    filter_type = filter_from_string(ft)

    {:noreply,
     socket
     |> assign(filter_type, Map.put(socket.assigns[filter_type], key, {String.to_atom(action), val}))
     |> push_state_update()
     |> push_event("reset_records", %{})}
  end

  @impl true
  def handle_event("remove_attr_filter", %{"key" => key, "filter_type" => ft}, socket) do
    filter_type = filter_from_string(ft)

    {:noreply,
     socket
     |> assign(filter_type, Map.delete(socket.assigns[filter_type], key))
     |> push_state_update()
     |> push_event("reset_records", %{})}
  end

  @impl true
  def handle_event("row_clicked", value, socket) do
    {:noreply, socket |> assign(:active_raw_data, value)}
  end

  # PubSub callbacks

  @impl true
  def handle_info({:agent_updated, message}, socket) do
    {:noreply, push_event(socket, "agent_update", serialize_agent(message))}
  end

  @impl true
  def handle_info({:agent_disconnected, _message}, socket) do
    {:noreply, push_event(socket, "agent_update", %{})}
  end

  @impl true
  def handle_info({:agent_deleted, _message}, socket) do
    {:noreply, push_event(socket, "agent_update", %{})}
  end

  @impl true
  def handle_info({:request_config, _message}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({data_type, message}, socket) do
    if data_type != socket.assigns.active_stream or not socket.assigns.should_stream do
      {:noreply, socket}
    else
      records =
        Filters.get_records(
          data_type,
          message,
          socket.assigns.filters,
          socket.assigns.resource_filters
        )

      socket = assign_available_filters(socket, records)

      {:noreply,
       socket
       |> push_event("records", %{records: records})
       |> push_state_update()}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  # Helpers

  defp push_state_update(socket) do
    push_event(socket, "state_update", %{
      should_stream: socket.assigns.should_stream,
      remote_tap_started: socket.assigns.remote_tap_started,
      active_stream: Atom.to_string(socket.assigns.active_stream),
      custom_columns: MapSet.to_list(socket.assigns.custom_columns),
      resource_columns: MapSet.to_list(socket.assigns.resource_columns),
      filters:
        Map.new(socket.assigns.filters, fn {k, {action, val}} ->
          {k, [Atom.to_string(action), val]}
        end),
      resource_filters:
        Map.new(socket.assigns.resource_filters, fn {k, {action, val}} ->
          {k, [Atom.to_string(action), val]}
        end),
      available_filters:
        Map.new(socket.assigns.available_filters, fn {k, v} -> {k, MapSet.to_list(v)} end),
      available_resource_filters:
        Map.new(socket.assigns.available_resource_filters, fn {k, v} ->
          {k, MapSet.to_list(v)}
        end)
    })
  end

  defp filter_from_string("resource"), do: :resource_filters
  defp filter_from_string("attributes"), do: :filters

  defp column_from_string("resource"), do: :resource_columns
  defp column_from_string("attributes"), do: :custom_columns

  def get_options do
    [:metrics, :spans, :logs]
    |> Enum.map(fn a ->
      %{stream: Atom.to_string(a), id: Atom.to_string(a), name: String.capitalize(Atom.to_string(a))}
    end)
  end

  defp toggle_remote_tap(socket) when socket.assigns.remote_tap_started do
    GenServer.stop(socket.assigns.remote_tap_pid, :normal)

    {:ok,
     socket
     |> assign(:remote_tap_pid, nil)
     |> assign(:remote_tap_started, false)}
  end

  defp toggle_remote_tap(socket) when socket.assigns.remote_tap_started == false do
    case Tails.RemoteTapClient.start_link([]) do
      {:ok, pid} ->
        {:ok,
         socket
         |> assign(:remote_tap_pid, pid)
         |> assign(:remote_tap_started, true)}

      {:error, reason} ->
        {:error, put_flash(socket, :error, reason)}
    end
  end

  defp assign_available_filters(socket, records) do
    current_state = {socket.assigns.available_filters, socket.assigns.available_resource_filters}

    {attributes, resource} =
      Enum.reduce(records, current_state, fn record, {attributes, resource} ->
        {update_kvs(Map.get(record, "attributes", []), attributes),
         update_kvs(Map.get(record, "resource", []), resource)}
      end)

    socket
    |> assign(:available_filters, attributes)
    |> assign(:available_resource_filters, resource)
  end

  defp update_kvs(attrs, previous) do
    Enum.reduce(attrs, previous, fn %{"key" => k, "value" => val}, acc ->
      stringified = Telemetry.string_from_value(val)
      Map.update(acc, k, MapSet.new([stringified]), fn ms -> MapSet.put(ms, stringified) end)
    end)
  end

  defp serialize_agent(agent) do
    %{
      id: agent[:id],
      connected: agent[:connected],
      description: serialize_description(agent[:description]),
      effective_config: serialize_effective_config(agent[:effective_config]),
      component_health: serialize_health(agent[:component_health]),
      remote_config_status: serialize_remote_config_status(agent[:remote_config_status])
    }
  end

  defp serialize_description(%Opamp.Proto.AgentDescription{} = d) do
    %{
      identifying_attributes: serialize_kvs(d.identifying_attributes),
      non_identifying_attributes: serialize_kvs(d.non_identifying_attributes)
    }
  end

  defp serialize_description(_), do: nil

  defp serialize_kvs(attrs) when is_list(attrs) do
    Enum.map(attrs, fn %Opamp.Proto.KeyValue{key: k, value: v} ->
      %{key: k, value: Tails.OpAMP.Helpers.clean_any_value(v) || ""}
    end)
  end

  defp serialize_kvs(_), do: []

  defp serialize_effective_config(%Opamp.Proto.EffectiveConfig{
         config_map: %Opamp.Proto.AgentConfigMap{config_map: cm}
       }) do
    Map.new(cm, fn {k, %Opamp.Proto.AgentConfigFile{body: body, content_type: ct}} ->
      {k, %{body: body, content_type: ct}}
    end)
  end

  defp serialize_effective_config(_), do: nil

  defp serialize_health(%Opamp.Proto.ComponentHealth{} = h) do
    %{
      healthy: h.healthy,
      status: h.status,
      last_error: h.last_error,
      component_health_map:
        Map.new(h.component_health_map, fn {k, v} -> {k, serialize_health(v)} end)
    }
  end

  defp serialize_health(_), do: nil

  defp serialize_remote_config_status(%Opamp.Proto.RemoteConfigStatus{} = s) do
    %{status: Atom.to_string(s.status), error_message: s.error_message}
  end

  defp serialize_remote_config_status(_), do: nil
end

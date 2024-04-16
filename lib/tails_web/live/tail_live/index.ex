defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias TailsWeb.Common.{Buttons, Slideover}
  alias Tails.{Telemetry, Agents, Filters}
  alias TailsWeb.Otel.{Attributes, DataViewer}
  @stream_limit 1000

  @columns %{
    :metrics => [
      "timeUnixNano",
      "Name",
      "Description"
    ],
    :spans => [
      "StartTimeUnixNano",
      "EndTimeUnixNano",
      "TraceId",
      "ParentSpanId",
      "SpanId",
      "Name",
      "Kind",
      "Status"
    ],
    :logs => [
      "timeUnixNano",
      "severityText",
      "spanId",
      "body"
    ]
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = Telemetry.subscribe()
    end

    if connected?(socket) do
      :ok = Agents.subscribe()
    end

    {:ok,
     socket
     |> stream(:data, [], at: -1, limit: -@stream_limit)
     |> assign(:modal_attributes, %{})
     |> assign(:modal_type, "attributes")
     |> assign(:active_raw_data, %{})
     |> assign(:agent, %{})
     |> assign(:columns, @columns)
     |> assign(:custom_columns, MapSet.new([]))
     |> assign(:resource_columns, MapSet.new([]))
     |> assign(:available_filters, %{})
     |> assign(:available_resource_filters, %{})
     |> assign(:filters, %{})
     |> assign(:resource_filters, %{})
     |> assign(:remote_tap_started, false)
     |> assign(:should_stream, true)
     |> assign(:stream_options, get_options())
     |> assign(:active_stream, :spans)}
  end

  @impl true
  def handle_event("change_stream", params, socket) do
    {:noreply,
     socket
     |> assign(:active_stream, String.to_existing_atom(String.downcase(params["value"])))
     |> stream(:data, [], reset: true)}
  end

  @impl true
  def handle_event("toggle_stream", _value, socket) do
    {:noreply,
     socket
     |> assign(:should_stream, !socket.assigns.should_stream)}
  end

  @impl true
  def handle_event("toggle_navbar_menu", _value, socket) do
    # JS.toggle(to: "#menu", in: "fade-in-scale", out: "fade-out-scale")
    {:noreply,
     socket
     |> push_event("js-exec", %{to: "#collector", attr: "data-show"})}
  end

  @impl true
  def handle_event("toggle_remote_tap", _value, socket) do
    case toggle_remote_tap(socket) do
      {:ok, socket} ->
        {:noreply, socket}

      {:error, socket} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("request_config", _value, socket) do
    :ok = request_new_config(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("slideover_cancel", _value, socket) do
    {:noreply,
     socket
     |> push_event("js-exec", %{to: "#menu", attr: "data-cancel"})
     |> assign(:active_raw_data, %{})}
  end

  @impl true
  def handle_event("row_clicked", value, socket) do
    {:noreply,
     socket
     |> assign(:active_raw_data, value)
     |> push_event("js-exec", %{to: "#row-data", attr: "data-show"})}
  end

  @impl true
  def handle_event(
        "update_columns",
        %{
          "column_type" => column_type_string,
          "key" => key
        },
        socket
      ) do
    {:noreply,
     socket
     |> update_columns(
       column_from_string(column_type_string),
       key,
       :add
     )}
  end

  @impl true
  def handle_event(
        "update_filters",
        %{
          "action" => action,
          "filter_type" => filter_type_string,
          "key" => key,
          "val" => val,
          "value" => _value
        },
        socket
      ) do
    {:noreply,
     socket
     |> update_filters(
       filter_from_string(filter_type_string),
       key,
       String.to_atom(action),
       val,
       :add
     )}
  end

  @impl true
  def handle_event(
        "remove_column",
        %{"column" => column, "column_type" => column_type_string},
        socket
      ) do
    {:noreply,
     socket
     |> put_flash(:info, "column removed, data reset")
     |> update_columns(column_from_string(column_type_string), column, :remove)}
  end

  @impl true
  def handle_event(
        "remove_attr_filter",
        %{"key" => key, "filter_type" => filter_type_string},
        socket
      ) do
    {:noreply,
     socket
     |> put_flash(:info, "filter removed, data reset")
     |> update_filters(
       filter_from_string(filter_type_string),
       key,
       nil,
       nil,
       :remove
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({:agent_deleted, _message}, socket) do
    {:noreply,
     socket
     |> assign(:agent, %{})}
  end

  @impl true
  def handle_info({:agent_updated, message}, socket) do
    {:noreply,
     socket
     |> assign(:agent, message)}
  end

  @impl true
  def handle_info({:agent_created, message}, socket) do
    if socket.assigns.remote_tap_started do
      {:noreply, assign(socket, :agent, message)}
    else
      case toggle_remote_tap(socket) do
        {:ok, socket} ->
          {:noreply, assign(socket, :agent, message)}

        {:error, socket} ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_info({:request_config, _message}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({data_type, message}, socket) do
    if data_type != socket.assigns.active_stream do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> bulk_insert_records(data_type, message)}
    end
  end

  defp filter_from_string(filter_type_string) when filter_type_string == "resource",
    do: :resource_filters

  defp filter_from_string(filter_type_string) when filter_type_string == "attributes",
    do: :filters

  defp column_from_string(column_type_string) when column_type_string == "resource",
    do: :resource_columns

  defp column_from_string(column_type_string) when column_type_string == "attributes",
    do: :custom_columns

  defp update_columns(socket, column_type, key, :add) do
    socket
    |> assign(column_type, MapSet.put(socket.assigns[column_type], key))
    |> stream(:data, [], reset: true)
  end

  defp update_columns(socket, column_type, key, :remove) do
    socket
    |> assign(column_type, MapSet.delete(socket.assigns[column_type], key))
    |> stream(:data, [], reset: true)
  end

  defp update_filters(socket, filter_type, key, action, val, :add) do
    socket
    |> assign(filter_type, Map.put(socket.assigns[filter_type], key, {action, val}))
    |> stream(:data, [], reset: true)
  end

  defp update_filters(socket, filter_type, key, _action, _val, :remove) do
    socket
    |> assign(filter_type, Map.delete(socket.assigns[filter_type], key))
    |> stream(:data, [], reset: true)
  end

  defp request_new_config(socket) do
    if !Map.has_key?(socket.assigns.agent, :effective_config) do
      Agents.request_latest_config()
    else
      :ok
    end
  end

  def get_options() do
    [:metrics, :spans, :logs]
    |> Enum.map(fn a ->
      %{stream: a, id: Atom.to_string(a), name: String.capitalize(Atom.to_string(a))}
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

  def bulk_insert_records(socket, data_type, message) do
    if socket.assigns.should_stream do
      records =
        Filters.get_records(
          data_type,
          message,
          socket.assigns.filters,
          socket.assigns.resource_filters
        )

      socket
      |> assign_available_filters(records)
      |> stream(:data, records, at: 0, limit: -@stream_limit)
    else
      socket
    end
  end

  defp assign_available_filters(socket, records) do
    current_state = {socket.assigns.available_filters, socket.assigns.available_resource_filters}

    {attributes, resource} =
      Enum.reduce(records, current_state, fn record, {attributes, resource} ->
        {update_kvs(record["attributes"], attributes), update_kvs(record["resource"], resource)}
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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tails")
    |> assign(:tail, nil)
  end
end

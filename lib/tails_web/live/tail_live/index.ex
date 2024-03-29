defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.{Telemetry, Agents, Filters}
  alias TailsWeb.Otel.{Attributes, ResourceData}
  @stream_limit 1000

  @columns %{
    :metrics => [
      "UTC Time",
      "Name",
      "Description"
    ],
    :spans => [
      "TraceId",
      "ParentSpanId",
      "SpanId",
      "StartTimeUnixNano",
      "EndTimeUnixNano",
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
    if connected?(socket), do: Telemetry.subscribe()
    if connected?(socket), do: Agents.subscribe()

    {:ok,
     socket
     |> stream(:data, [], at: -1, limit: -@stream_limit)
     |> assign(:modal_attributes, %{})
     |> assign(:modal_type, "attributes")
     |> assign(:config, %{})
     |> assign(:columns, @columns)
     |> assign(:custom_columns, MapSet.new([]))
     |> assign(:resource_columns, MapSet.new([]))
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
     |> push_event("reset", %{})
     |> push_event("js-exec", %{to: "#menu", attr: "data-show"})}
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
    request_new_config(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("attribute_clicked", value, socket) do
    {:noreply,
     socket
     |> assign(:modal_attributes, value["attributes"])
     |> assign(:modal_type, "attributes")
     |> push_event("js-exec", %{to: "#attribute-modal", attr: "data-show"})}
  end

  @impl true
  def handle_event("resource_attribute_clicked", value, socket) do
    {:noreply,
     socket
     |> assign(:modal_attributes, value["resource"])
     |> assign(:modal_type, "resource")
     |> push_event("js-exec", %{to: "#attribute-modal", attr: "data-show"})}
  end

  @impl true
  def handle_event("remove_column", %{"column" => column, "column_type" => column_type}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "column removed, data reset")
     |> remove_column(column, column_type)
     |> stream(:data, [], reset: true)}
  end

  @impl true
  def handle_event("remove_attr_filter", %{"key" => key, "filter_type" => filter_type}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "filter removed, data reset")
     |> remove_filter(key, filter_type)
     |> stream(:data, [], reset: true)}
  end

  @impl true
  def handle_event("attribute_filter", %{"action" => action, "key" => key, "val" => val}, socket) do
    case action do
      "column" ->
        {:noreply,
         socket
         |> put_flash(:info, "column added, data reset")
         |> assign_columns(key)
         |> stream(:data, [], reset: true)}

      "include" ->
        {:noreply,
         socket
         |> put_flash(:info, "include filter added, data reset")
         |> assign_filters(:include, key, val)}

      "filter" ->
        {:noreply,
         socket
         |> put_flash(:info, "exclude filter added, data reset")
         |> assign_filters(:exclude, key, val)}

      "_" ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({:agent_deleted, _message}, socket) do
    {:noreply,
     socket
     |> assign(:config, %{})}
  end

  @impl true
  def handle_info({:agent_updated, message}, socket) do
    {:noreply,
     socket
     |> assign(:config, message)}
  end

  @impl true
  def handle_info({:agent_created, message}, socket) do
    if socket.assigns.remote_tap_started do
      {:noreply, assign(socket, :config, message)}
    else
      case toggle_remote_tap(socket) do
        {:ok, socket} ->
          {:noreply, assign(socket, :config, message)}

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

  defp remove_column(socket, column, column_type) when column_type == "attributes",
    do: assign(socket, :custom_columns, MapSet.delete(socket.assigns.custom_columns, column))

  defp remove_column(socket, column, column_type) when column_type == "resource",
    do: assign(socket, :resource_columns, MapSet.delete(socket.assigns.resource_columns, column))

  defp remove_column(socket, _column, _column_type), do: socket

  defp remove_filter(socket, key, filter_type) when filter_type == "attributes",
    do: assign(socket, :filters, Map.delete(socket.assigns.filters, key))

  defp remove_filter(socket, key, filter_type) when filter_type == "resource",
    do: assign(socket, :resource_filters, Map.delete(socket.assigns.resource_filters, key))

  defp remove_filter(socket, _key, _filter_type), do: socket

  defp assign_columns(socket, key) when socket.assigns.modal_type == "resource",
    do: assign(socket, :resource_columns, MapSet.put(socket.assigns.resource_columns, key))

  defp assign_columns(socket, key) when socket.assigns.modal_type == "attributes",
    do: assign(socket, :custom_columns, MapSet.put(socket.assigns.custom_columns, key))

  defp assign_columns(socket, _key), do: socket

  defp assign_filters(socket, action, key, val) when socket.assigns.modal_type == "resource" do
    socket
    |> assign(:resource_filters, Map.put(socket.assigns.resource_filters, key, {action, val}))
    |> stream(:data, [], reset: true)
  end

  defp assign_filters(socket, action, key, val) when socket.assigns.modal_type == "attributes" do
    socket
    |> assign(:filters, Map.put(socket.assigns.filters, key, {action, val}))
    |> stream(:data, [], reset: true)
  end

  defp assign_filters(socket, _action, _key, _val), do: socket

  defp request_new_config(socket) do
    if !Map.has_key?(socket.assigns.config, :effective_config) do
      Agents.request_latest_config()
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

  defp toggle_remote_tap(socket) do
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
        get_records(data_type, message, socket.assigns.filters, socket.assigns.resource_filters)

      socket
      |> stream(:data, records, at: -1, limit: -@stream_limit)
    else
      socket
    end
  end

  def get_records(stream_name, message, filters, resource_filters) do
    message.data[resource_accessor(stream_name)]
    |> Enum.reduce([], fn resourceRecord, resourceAcc ->
      case keep_record?(resourceRecord["resource"], resource_filters) do
        {true, _} -> resourceAcc ++ flatten_records(resourceRecord, stream_name, filters)
        {false, _} -> resourceAcc
      end
    end)
  end

  defp flatten_records(resourceRecord, stream_name, filters) do
    resourceRecord[scope_accessor(stream_name)]
    |> Enum.flat_map(fn scopeRecord ->
      scopeRecord[record_accessor(stream_name)]
      |> Enum.reduce([], fn item, acc ->
        item
        |> Map.put_new(:id, UUID.uuid4())
        |> normalize()
        |> Map.put_new("resource", resourceRecord["resource"]["attributes"])
        |> keep_record?(filters)
        |> append_record?(acc)
      end)
    end)
  end

  defp append_record?({true, record}, acc), do: acc ++ [record]
  defp append_record?({false, _record}, acc), do: acc

  defp keep_record?(record, filters),
    do: {Filters.keep_record(record["attributes"], filters), record}

  defp resource_accessor(stream_name),
    do: "resource#{String.capitalize(Atom.to_string(stream_name))}"

  defp scope_accessor(stream_name), do: "scope#{String.capitalize(Atom.to_string(stream_name))}"
  defp record_accessor(:logs), do: "logRecords"
  defp record_accessor(stream_name), do: Atom.to_string(stream_name)

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tails")
    |> assign(:tail, nil)
  end

  defp normalize(%{"histogram" => %{"dataPoints" => data_points}} = data),
    do: Map.put(data, "attributes", get_attributes_from_metric(data_points))

  defp normalize(%{"gauge" => %{"dataPoints" => data_points}} = data),
    do: Map.put(data, "attributes", get_attributes_from_metric(data_points))

  defp normalize(%{"sum" => %{"dataPoints" => data_points}} = data),
    do: Map.put(data, "attributes", get_attributes_from_metric(data_points))

  defp normalize(data), do: data

  defp get_attributes_from_metric(data_points) do
    data_points
    |> Enum.reduce([], fn point, acc -> point["attributes"] ++ acc end)
  end
end

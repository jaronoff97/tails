defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.{Telemetry, Agents}
  alias TailsWeb.Otel.{Resource, ResourceData}
  @stream_limit 1000

  @columns %{
    :metrics => [
      "UTC Time",
      "Name",
      "Description",
      "Attributes",
      "Resource"
    ],
    :spans => [
      "TraceId",
      "ParentSpanId",
      "SpanId",
      "StartTimeUnixNano",
      "EndTimeUnixNano",
      "Name",
      "Kind",
      "Status",
      "Attributes",
      "Resource"
    ],
    :logs => [
      "timeUnixNano",
      "severityText",
      "spanId",
      "body",
      "Attributes",
      "Resource"
    ]
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Telemetry.subscribe()
    if connected?(socket), do: Agents.subscribe()

    {:ok,
     socket
     |> stream(:data, [], at: -1, limit: -@stream_limit)
     |> assign(:config, %{})
     |> assign(:columns, @columns)
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
  def handle_event("toggle_remote_tap", _value, socket) do
    case start_remote_tap(socket) do
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

  def toggle_navbar_menu(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#menu", in: "fade-in-scale", out: "fade-out-scale")
  end

  defp request_new_config(socket) do
    if !Map.has_key?(socket.assigns.config, :effective_config) do
      Agents.request_latest_config()
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
    case start_remote_tap(socket) do
      {:ok, socket} ->
        {:noreply,
         socket
         |> assign(:config, message)}

      {:error, socket} ->
        {:noreply, socket}
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

  def get_options() do
    [:metrics, :spans, :logs]
    |> Enum.map(fn a ->
      %{stream: a, id: Atom.to_string(a), name: String.capitalize(Atom.to_string(a))}
    end)
  end

  defp start_remote_tap(socket) when socket.assigns.remote_tap_started, do: {:ok, socket}

  defp start_remote_tap(socket) do
    case Tails.RemoteTapClient.start_link([]) do
      {:ok, _pid} ->
        {:ok,
         socket
         |> assign(:remote_tap_started, true)}

      {:error, reason} ->
        {:error, put_flash(socket, :error, reason)}
    end
  end

  def bulk_insert_records(socket, data_type, message) do
    if socket.assigns.should_stream do
      IO.inspect(get_records(data_type, message))

      socket
      |> stream(:data, get_records(data_type, message), at: -1, limit: -@stream_limit)
    else
      socket
    end
  end

  def get_records(stream_name, message) do
    message.data[resource_accessor(stream_name)]
    |> Enum.map(fn resourceRecords ->
      Map.update(resourceRecords, scope_accessor(stream_name), [], fn scopeRecords ->
        Enum.map(scopeRecords, fn scopeRecord ->
          Map.update(scopeRecord, record_accessor(stream_name), [], fn records ->
            Enum.map(records, fn item -> Map.put_new(item, :id, UUID.uuid4()) end)
          end)
        end)
      end)
    end)
    |> Enum.map(fn resourceRecords -> Map.put_new(resourceRecords, :id, UUID.uuid4()) end)
  end

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
end

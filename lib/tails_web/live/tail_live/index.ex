defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.{Telemetry, Agents}
  alias TailsWeb.Otel.{Resource, Span, Metric, Log}

  @columns %{
    "Metrics" => [
      "Unix time",
      "Name",
      "Description",
      "Attributes"
    ],
    "Spans" => [
      "TraceId",
      "ParentSpanId",
      "SpanId",
      "StartTimeUnixNano",
      "EndTimeUnixNano",
      "Name",
      "Kind",
      "Status",
      "Attributes"
    ],
    "Logs" => [
      "timeUnixNano",
      "severityText",
      "spanId",
      "body",
      "attributes"
    ]
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Telemetry.subscribe()
    if connected?(socket), do: Agents.subscribe()

    {:ok,
     socket
     |> stream(:spans, [], at: -1, limit: -10)
     |> stream(:metrics, [], at: -1, limit: -10)
     |> stream(:logs, [], at: -1, limit: -10)
     |> assign(:config, %{})
     |> assign(:resource, %{"attributes" => []})
     |> assign(:columns, @columns)
     |> assign(:remote_tap_started, false)
     |> assign(:form, to_form(%{"item" => "Spans"}))}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply,
     socket
     |> assign(:resource, %{"attributes" => []})
     |> assign(form: to_form(%{"item" => params["item"]}))}
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
    # IO.inspect(message)

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
    {_ok, socket} = start_remote_tap(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({stream_name, message}, socket) do
    {:noreply,
     socket
     |> bulk_insert_records(stream_name, message)
     |> get_resource(stream_name, message)}
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

  def bulk_insert_records(socket, stream_name, message) do
    socket
    |> stream(stream_name, get_records(stream_name, message))
  end

  def get_records(stream_name, message) do
    message.data["resource#{String.capitalize(Atom.to_string(stream_name))}"]
    |> Enum.reduce([], fn e, acc ->
      acc ++ e["scope#{String.capitalize(Atom.to_string(stream_name))}"]
    end)
    |> Enum.reduce([], fn e, acc ->
      acc ++ e[record_accessor(stream_name)]
    end)
    |> Enum.map(fn item -> Map.put_new(item, :id, UUID.uuid4()) end)
  end

  defp record_accessor(:logs), do: "logRecords"
  defp record_accessor(stream_name), do: Atom.to_string(stream_name)

  defp get_resource(socket, stream_name, message) do
    if String.downcase(socket.assigns.form.params["item"]) == Atom.to_string(stream_name) do
      new_resource =
        message.data["resource#{String.capitalize(Atom.to_string(stream_name))}"]
        |> Enum.reduce(%{"attributes" => []}, fn e, acc ->
          Map.merge(acc, e["resource"])
        end)

      socket
      |> assign(:resource, new_resource)
    else
      socket
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tails")
    |> assign(:tail, nil)
  end
end

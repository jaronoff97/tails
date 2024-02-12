defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.Telemetry
  alias TailsWeb.Otel.{Resource, Spans, Metrics}

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
    "Logs" => []
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Telemetry.subscribe()

    {:ok,
     socket
     |> stream(:spans, [], at: -1, limit: -10)
     |> stream(:metrics, [], at: -1, limit: -10)
     |> stream(:logs, [], at: -1, limit: -10)
     |> assign(:resource, %{"attributes" => []})
     |> assign(:columns, @columns)
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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({stream_name, message}, socket) do
    # IO.inspect(message)

    {:noreply,
     socket
     |> stream_insert(stream_name, message)
     |> get_resource(stream_name, message)}
  end

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

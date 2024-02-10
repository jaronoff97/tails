defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.Telemetry
  alias TailsWeb.Otel.{Resource, Span}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Telemetry.subscribe()

    {:ok,
     socket
     |> stream(:spans, [])
     |> stream(:metrics, [])
     |> stream(:logs, [])
     |> assign(:form, to_form(%{"item" => "Spans"}))}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, form: to_form(%{"item" => params["item"]}))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({stream_name, message}, socket) do
    {:noreply, stream_insert(socket, stream_name, message, at: 0)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tails")
    |> assign(:tail, nil)
  end

  defp get_spans(resourceSpans) do
    resourceSpans
    |> Enum.reduce([], fn e, acc ->
      acc ++ e["scopeSpans"]
    end)
    |> Enum.reduce([], fn e, acc ->
      acc ++ e["spans"]
    end)
  end
end

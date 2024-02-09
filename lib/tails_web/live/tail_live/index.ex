defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.Telemetry
  alias TailsWeb.Otel.Resource

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
  def handle_info({:new_span, message}, socket) do
    {:noreply, stream_insert(socket, :spans, message)}
  end

  @impl true
  def handle_info({:new_metric, message}, socket) do
    {:noreply, stream_insert(socket, :metrics, message)}
  end

  @impl true
  def handle_info({:new_log, message}, socket) do
    {:noreply, stream_insert(socket, :logs, message)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tails")
    |> assign(:tail, nil)
  end
end

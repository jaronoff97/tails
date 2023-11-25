defmodule TailsWeb.TailLive.Index do
  use TailsWeb, :live_view

  alias Tails.Telemetry

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Telemetry.subscribe()
    {:ok, stream(socket, :messages, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tails")
    |> assign(:tail, nil)
  end
end

defmodule TailsWeb.Common.Buttons do
  use Phoenix.Component

  @doc """
  Renders a Button.

  """
  attr :id, :string, required: true
  attr :text, :string, default: ""
  attr :icon, :atom, values: [:pause, :play, :none], default: :none
  attr :phx_click, :string, required: false

  def navbar_button(assigns) do
    ~H"""
    <button id={@id} phx-click={@phx_click}>
      <%= if @icon != :none do %>
        <.icon icon={@icon} />
      <% end %>
    </button>
    <span class="ms-3 text-sm font-medium text-gray-900 dark:text-gray-300">
      <%= @text %>
    </span>
    """
  end

  def icon(%{icon: :play} = assigns) do
    ~H"""
    <svg
      class="w-[20px] h-[20px] text-gray-800 stroke-black"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      fill="none"
      viewBox="0 0 24 24"
    >
      <path
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M10 9v6m4-6v6m7-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
      />
    </svg>
    """
  end

  def icon(%{icon: :pause} = assigns) do
    ~H"""
    <svg
      class="w-[20px] h-[20px] text-gray-800  stroke-black"
      aria-hidden="true"
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      fill="none"
      viewBox="0 0 24 24"
    >
      <path
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M8 18V6l8 6-8 6Z"
      />
    </svg>
    """
  end

  def icon(%{icon: :green_check} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="#29E41B"
      class="w-6 h-6 align-middle inline-block"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
      />
    </svg>
    """
  end

  def icon(%{icon: :refresh} = assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      class="w-6 h-6 align-middle inline-block"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
      />
    </svg>
    """
  end
end

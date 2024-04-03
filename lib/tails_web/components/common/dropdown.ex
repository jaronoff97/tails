defmodule TailsWeb.Common.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr(:id, :string, required: true)
  slot(:button, required: true)

  slot :item, required: true do
    attr :id, :string, required: true
  end

  def dropdown(assigns) do
    ~H"""
    <div class="relative" data-component={"#{@id}-dropdown"}>
      <button
        type="button"
        class="flex items-center p-2 w-full text-base font-medium text-gray-900 rounded-lg transition duration-75 group hover:bg-gray-100 dark:text-white dark:hover:bg-gray-700"
        id={"#{@id}-button"}
        aria-expanded="false"
        phx-click={JS.toggle(to: "##{@id}-menu", in: "fade-in-scale", out: "fade-out-scale")}
      >
        <span class="flex-1 ml-3 text-left whitespace-nowrap">
          <%= render_slot(@button) %>
        </span>
        <svg
          aria-hidden="true"
          class="w-6 h-6"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fill-rule="evenodd"
            d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
            clip-rule="evenodd"
          >
          </path>
        </svg>
      </button>
      <ul id={"#{@id}-menu"} class="hidden py-2 space-y-2" data-cancel={JS.exec(%JS{}, "phx-remove")}>
        <li :for={item <- @item}>
          <div class="block items-center p-2 pl-11 w-full text-base font-medium text-gray-900 rounded-lg transition duration-75 group dark:text-white ">
            <%= render_slot(item) %>
          </div>
        </li>
      </ul>
    </div>
    """
  end
end

defmodule TailsWeb.Common.MoreButton do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a More Button.

  """
  attr :id, :string, required: true

  slot :item, required: true do
    attr :id, :string, required: true
  end

  def more(assigns) do
    ~H"""
    <button
      id={@id}
      data-dropdown-toggle={"#{@id}-dots"}
      class="inline-flex items-center p-2 text-sm font-medium text-center text-gray-900 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 focus:ring-4 focus:outline-none focus:ring-gray-50 dark:focus:ring-gray-600"
      type="button"
      phx-click={JS.toggle(to: "##{@id}-dots", in: "fade-in-scale", out: "fade-out-scale")}
    >
      <svg
        class="w-5 h-5 text-gray-800 dark:text-white"
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
          stroke-width="2"
          d="M12 6h.01M12 12h.01M12 18h.01"
        />
      </svg>
    </button>
    <!-- Dropdown menu -->
    <div
      id={"#{@id}-dots"}
      class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600 relative"
    >
      <ul
        id={"#{@id}-menu"}
        class="py-2 text-sm text-gray-700 dark:text-gray-200"
        aria-labelledby={@id}
        data-cancel={JS.exec(%JS{}, "phx-remove")}
      >
        <li :for={item <- @item}>
          <a
            href="#"
            class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
          >
            <%= render_slot(item) %>
          </a>
        </li>
      </ul>
    </div>
    """
  end
end

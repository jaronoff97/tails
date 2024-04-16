defmodule TailsWeb.Common.FilterDropdown do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias TailsWeb.Common.MoreButton

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :filter_string, "")}
  end

  @impl true
  def handle_event("update_filter", %{"filter" => filter} = _rest, socket) do
    {:noreply, assign(socket, :filter_string, filter)}
  end

  defp filter_list(values, filter_string) do
    Stream.filter(values, fn v -> String.contains?(v, filter_string) end)
  end

  attr(:id, :string, required: true)
  attr(:button_title, :string, required: true)
  attr(:key, :string, required: true)
  attr(:values, :list, required: true)

  def render(assigns) do
    ~H"""
    <div class="relative" data-component={"#{@id}-dropdown"}>
      <div class="flex">
        <button
          type="button"
          class="flex items-center w-full  rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 focus:ring-4 focus:outline-none focus:ring-gray-50 dark:focus:ring-gray-600"
          id={"#{@id}-button"}
          aria-expanded="false"
          phx-target={@myself}
          phx-click={JS.toggle(to: "##{@id}-menu", in: "fade-in-scale", out: "fade-out-scale")}
        >
          <span class="flex-1 ml-3 text-left whitespace-nowrap">
            <%= @button_title %>
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
        <%!-- <MoreButton.more id={"#{@id}-more"}>
          <:item id={"#{@id}-test"}>
            test
          </:item>
        </MoreButton.more> --%>
      </div>
      <div class="hidden py-2 space-y-2" id={"#{@id}-menu"} data-cancel={JS.exec(%JS{}, "phx-remove")}>
        <form
          class="flex items-center max-w-sm mx-auto"
          phx-change="update_filter"
          phx-target={@myself}
        >
          <div class="relative w-full">
            <input
              type="text"
              id={"#{@id}-filter-input"}
              class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full ps-10 p-2.5  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
              placeholder="Filter list..."
              name="filter"
              value={@filter_string}
              required
            />
          </div>
        </form>
        <ul>
          <li :for={v <- filter_list(@values, @filter_string)}>
            <div class="block items-center p-2 pl-11 w-full text-base font-medium">
              <div>
                <div class="flex items-center">
                  <button
                    id={"#{@id}-#{v}-include"}
                    phx-value-filter_type={@filter_type}
                    phx-value-key={@key}
                    phx-value-val={v}
                    phx-value-action="include"
                    phx-click="update_filters"
                  >
                    <svg
                      class="w-[20px] h-[20px] text-gray-800 dark:text-white"
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
                        d="M12 7.757v8.486M7.757 12h8.486M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                      />
                    </svg>
                  </button>
                  <button
                    id={"#{@id}-#{v}-exclude"}
                    phx-value-filter_type={@filter_type}
                    phx-value-key={@key}
                    phx-value-val={v}
                    phx-value-action="exclude"
                    phx-click="update_filters"
                  >
                    <svg
                      class="w-[20px] h-[20px] text-gray-800 dark:text-white"
                      aria-hidden="true"
                      xmlns="http://www.w3.org/2000/svg"
                      width="24"
                      height="24"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <path
                        d="M8 12H16M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      >
                      </path>
                    </svg>
                  </button>
                  <label class="ml-3">
                    <%= v %>
                  </label>
                </div>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end

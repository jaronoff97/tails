defmodule FilterSidebar do
  alias TailsWeb.Common.Dropdown
  alias TailsWeb.Common.FilterDropdown
  alias FilterDropdown
  alias Dropdown

  use Phoenix.Component

  # This is a shameful hack because apparently dots in ids are a no no?
  defp generate_id_from_key(key) do
    String.replace(key, ".", "-")
  end

  defp sorted_attrs(attrs) do
    Enum.sort_by(attrs, &String.first(elem(&1, 0)))
  end

  def showFilterSidebar(assigns) do
    ~H"""
    <div id="default-sidebar" class="w-80 h-min rounded-lg dark:bg-gray-600">
      <div class="w-80 px-3 py-4 overflow-y-auto">
        <!-- Metrics/Spans/Logs header radio buttons
        -->
        <h2 class="text-2xl font-extrabold dark:text-white">Telemetry Type</h2>
        <hr class="solid" />
        <div id="metrics-spans-logs-button-group" class="mx-auto w-min">
          <ul class="m-5 text-sm font-medium text-gray-900 sm:flex dark:text-white">
            <li :for={option <- @stream_options} class="pr-5">
              <div class="flex items-center mb-4">
                <input
                  class="w-4 h-4 text-blue-600 focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2"
                  checked={@active_stream == option.stream}
                  value={option.name}
                  type="radio"
                  id={"#{option.id}"}
                  name={option.name}
                  phx-click="change_stream"
                />
                <label
                  class="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
                  for={"#{option.id}"}
                >
                  <%= String.capitalize(option.name) %>
                </label>
              </div>
            </li>
          </ul>
        </div>
        <!-- End of Metrics/Spans/Logs -->
        <h2 class="text-2xl font-extrabold dark:text-white">Filters</h2>
        <hr class="solid pb-5" />
        <ul class=" font-medium">
          <li>
            <Dropdown.dropdown id="attribute">
              <:button>
                Attributes
              </:button>

              <:item :for={{k, values} <- sorted_attrs(@available_filters)} id={"#{k}-attr-item"}>
                <.live_component
                  module={FilterDropdown}
                  id={"#{generate_id_from_key(k)}-attribute-filter-dropdown"}
                  key={k}
                  values={values}
                  button_title={k}
                  filter_type="attributes"
                />
              </:item>
            </Dropdown.dropdown>
          </li>
          <li>
            <Dropdown.dropdown id="resource">
              <:button>
                Resource
              </:button>

              <:item
                :for={{k, values} <- sorted_attrs(@available_resource_filters)}
                id={"#{k}-resource-item"}
              >
                <.live_component
                  module={FilterDropdown}
                  id={"#{generate_id_from_key(k)}-resource-filter-dropdown"}
                  key={k}
                  values={values}
                  button_title={k}
                  filter_type="resource"
                />
              </:item>
            </Dropdown.dropdown>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end

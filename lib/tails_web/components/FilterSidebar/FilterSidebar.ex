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

  def showFilterSidebar(assigns) do
    ~H"""
    <div id="default-sidebar" class="w-80 h-min rounded-lg dark:bg-gray-600">
      <div class="w-80 px-3 py-4 overflow-y-auto">
        <h2 class="text-2xl font-extrabold dark:text-white">Filters</h2>
        <hr class="solid pb-5" />
        <ul class=" font-medium">
          <li>
            <Dropdown.dropdown id="attribute">
              <:button>
                Attributes
              </:button>

              <:item :for={{k, values} <- @available_filters} id={"#{k}-attr-item"}>
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

              <:item :for={{k, values} <- @available_resource_filters} id={"#{k}-resource-item"}>
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

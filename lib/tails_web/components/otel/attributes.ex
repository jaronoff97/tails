defmodule TailsWeb.Otel.Attributes do
  use Phoenix.Component
  import TailsWeb.CoreComponents
  alias Tails.Telemetry

  def show(assigns) do

    ~H"""
    <div>
      <.table id="attribute" rows={@data}>
        <:col :let={attribute} label="key"><%= attribute["key"] %></:col>
        <:col :let={attribute} label="value">
          <%= Telemetry.string_from_value(attribute["value"]) %>
        </:col>
        <:action :let={attribute}>
          <button
            phx-click="attribute_filter"
            phx-value-action="column"
            phx-value-key={attribute["key"]}
            phx-value-val=""
            class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-blue-500"
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
                d="M14 8H4m8 3.5v5M9.5 14h5M4 6v13a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V9a1 1 0 0 0-1-1h-5.032a1 1 0 0 1-.768-.36l-1.9-2.28a1 1 0 0 0-.768-.36H5a1 1 0 0 0-1 1Z"
              />
            </svg>

            <span class="sr-only">Icon description</span>
            Add Column
          </button>
        </:action>
        <:action :let={attribute}>
          <button
            phx-click="attribute_filter"
            phx-value-action="include"
            phx-value-key={attribute["key"]}
            phx-value-val=".*"
            class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-blue-500"
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
            <span class="sr-only">Icon description</span>
            Include Key
          </button>
        </:action>
        <:action :let={attribute}>
          <button
            phx-click="attribute_filter"
            phx-value-action="include"
            phx-value-key={attribute["key"]}
            phx-value-val={Telemetry.string_from_value(attribute["value"])}
            class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-blue-500"
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
            <span class="sr-only">Icon description</span>
            Include Key/Value
          </button>
        </:action>
        <:action :let={attribute}>
          <button
            phx-click="attribute_filter"
            phx-value-action="filter"
            phx-value-key={attribute["key"]}
            phx-value-val=".*"
            class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-blue-500"
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
                d="m15 9-6 6m0-6 6 6m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
              />
            </svg>
            <span class="sr-only">Icon description</span>
            Filter Key
          </button>
        </:action>
        <:action :let={attribute}>
          <button
            phx-click="attribute_filter"
            phx-value-action="filter"
            phx-value-key={attribute["key"]}
            phx-value-val={Telemetry.string_from_value(attribute["value"])}
            class="text-blue-700 border border-blue-700 hover:bg-blue-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-500 dark:text-blue-500 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-blue-500"
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
                d="m15 9-6 6m0-6 6 6m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
              />
            </svg>
            <span class="sr-only">Icon description</span>
            Filter Key/Value
          </button>
        </:action>
      </.table>
    </div>
    """
  end
end

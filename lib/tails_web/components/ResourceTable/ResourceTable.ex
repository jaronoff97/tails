defmodule ResourceTable do
  alias TailsWeb.Otel.ResourceData
  alias Phoenix.LiveView.JS
  use Phoenix.Component

  def showTable(assigns) do
    ~H"""
    <div id="table" class="w-full overflow-y-auto sm:overflow-visible sm:px-0 ml-6">
      <%= if @remote_tap_started do %>
        <table class="w-[40rem] sm:w-full">
          <thead class="text-sm text-left leading-6 text-zinc-500">
            <tr>
              <div :for={col_name <- @columns[@active_stream]}>
                <th class="p-0 pb-4 pr-6 font-normal dark:text-slate-50"><%= col_name %></th>
              </div>
              <div :for={col_name <- @custom_columns}>
                <th class="p-0 pb-4 pr-6 font-normal">
                  <span
                    id={"badge-dismiss-#{col_name}"}
                    class="inline-flex items-center px-2 py-1 me-2 text-sm font-medium text-yellow-800 bg-yellow-100 rounded dark:bg-yellow-900 dark:text-yellow-300"
                  >
                    <%= col_name %>
                    <button
                      type="button"
                      class="inline-flex items-center p-1 ms-2 text-sm text-yellow-400 bg-transparent rounded-sm hover:bg-yellow-200 hover:text-yellow-900 dark:hover:bg-yellow-800 dark:hover:text-yellow-300"
                      phx-click="remove_column"
                      phx-value-column={col_name}
                      phx-value-column_type="attributes"
                      aria-label="Remove"
                    >
                      <svg
                        class="w-2 h-2"
                        aria-hidden="true"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 14 14"
                      >
                        <path
                          stroke="currentColor"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                        />
                      </svg>
                      <span class="sr-only"><%= col_name %></span>
                    </button>
                  </span>
                </th>
              </div>
              <div :for={col_name <- @resource_columns}>
                <th class="p-0 pb-4 pr-6 font-normal">
                  <span
                    id={"badge-dismiss-#{col_name}"}
                    class="inline-flex items-center px-2 py-1 me-2 text-sm font-medium text-blue-800 bg-blue-100 rounded dark:bg-blue-900 dark:text-blue-300"
                  >
                    <%= col_name %>
                    <button
                      type="button"
                      class="inline-flex items-center p-1 ms-2 text-sm text-blue-400 bg-transparent rounded-sm hover:bg-blue-200 hover:text-blue-900 dark:hover:bg-blue-800 dark:hover:text-blue-300"
                      phx-click="remove_column"
                      phx-value-column={col_name}
                      phx-value-column_type="resource"
                      aria-label="Remove"
                    >
                      <svg
                        class="w-2 h-2"
                        aria-hidden="true"
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 14 14"
                      >
                        <path
                          stroke="currentColor"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                        />
                      </svg>
                      <span class="sr-only"><%= col_name %></span>
                    </button>
                  </span>
                </th>
              </div>
            </tr>
          </thead>

          <tbody
            id="data"
            phx-update="stream"
            class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
          >
            <tr
              :for={{row_id, row} <- @streams.data}
              id={row_id}
              class="group hover:bg-zinc-50 dark:text-slate-300"
            >
              <ResourceData.show
                data={row}
                stream_name={@active_stream}
                custom_columns={@custom_columns}
                resource_columns={@resource_columns}
                row_click={
                  fn data ->
                    JS.push("row_clicked", value: data)
                  end
                }
              />
            </tr>
          </tbody>
        </table>
      <% else %>
        <div class="flex justify-center items-center h-full">
          <button
            phx-click="toggle_remote_tap"
            hidden={@remote_tap_started}
            class="bg-blue-500 hover:bg-blue-700 focus:bg-blue-900 text-white font-bold py-2 px-4 rounded focus:shadow-outline active:bg-blue-900"
          >
            <h1>Remote tap not started, connect to agent</h1>
          </button>
        </div>
      <% end %>
    </div>
    """
  end
end

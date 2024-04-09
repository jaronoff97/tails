defmodule TailsWeb.Common.Slideover do
  use Phoenix.Component
  import TailsWeb.CoreComponents
  alias Phoenix.LiveView.JS

  @doc """
  Renders a slideover.

  """
  attr :id, :string, required: true
  attr :phx_click, :string, required: false
  slot :inner_block, required: true

  def slideover(assigns) do
    ~H"""
    <div
      class="relative z-10 hidden"
      aria-labelledby={"#{@id}-over-title"}
      role="dialog"
      aria-modal="true"
      phx-remove={
        hide_modal(
          @id,
          {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
        )
      }
      data-show={
        show_modal(
          @id,
          {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"}
        )
      }
      data-cancel={JS.exec(%JS{}, "phx-remove")}
      id={@id}
    >
      <!--
        Background backdrop, show/hide based on slide-over state.

        Entering: "ease-in-out duration-500"
          From: "opacity-0"
          To: "opacity-100"
        Leaving: "ease-in-out duration-500"
          From: "opacity-100"
          To: "opacity-0"
      -->
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75"></div>
      <div class="fixed inset-0 overflow-hidden">
        <div class="absolute inset-0 overflow-hidden">
          <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10 overflow-y-auto">
            <!--
              Slide-over panel, show/hide based on slide-over state.

              Entering: "transform transition ease-in-out duration-500 sm:duration-700"
                From: "translate-x-full"
                To: "translate-x-0"
              Leaving: "transform transition ease-in-out duration-500 sm:duration-700"
                From: "translate-x-0"
                To: "translate-x-full"
            -->
            <div class="pointer-events-auto relative w-screen max-w-md">
              <!--
                Close button, show/hide based on slide-over state.

                Entering: "ease-in-out duration-500"
                  From: "opacity-0"
                  To: "opacity-100"
                Leaving: "ease-in-out duration-500"
                  From: "opacity-100"
                  To: "opacity-0"
              -->
              <.focus_wrap
                id={"#{@id}-container"}
                phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
                phx-key="escape"
                phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              >
                <div class="absolute left-0 top-0 -ml-8 flex pr-2 pt-4 sm:-ml-10 sm:pr-4">
                  <button
                    type="button"
                    phx-click={JS.exec("data-cancel", to: "##{@id}")}
                    class="relative rounded-md text-gray-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white"
                  >
                    <span class="absolute -inset-2.5"></span>
                    <span class="sr-only">Close panel</span>
                    <svg
                      class="h-6 w-6"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="currentColor"
                      aria-hidden="true"
                    >
                      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>

                <div id={"#{@id}-content"} class="flex flex-col overflow-y-scroll shadow-xl">
                  <%= render_slot(@inner_block) %>
                </div>
              </.focus_wrap>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

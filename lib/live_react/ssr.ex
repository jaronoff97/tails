defmodule LiveReact.SSR.NotConfigured do
  @moduledoc false

  defexception [:message]
end

defmodule LiveReact.SSR do
  require Logger

  @moduledoc """
  A behaviour for rendering React components server-side.
  """

  @type component_name :: String.t()
  @type props :: %{optional(String.t() | atom) => any}
  @type slots :: %{optional(String.t()) => any}

  @type render_response :: %{optional(String.t() | atom) => any}

  @callback render(component_name, props, slots) :: render_response | no_return
  @spec render(component_name, props, slots) :: render_response | no_return
  def render(name, props, slots) do
    case Application.get_env(:tails, :ssr_module, nil) do
      nil ->
        Logger.error("No SSR Module available")
        %{preloadLinks: "", html: ""}

      mod ->
        case telemetry_wrapped_render(mod, name, props, slots) do
          body when is_binary(body) ->
            case String.split(body, "<!-- preload -->", parts: 2) do
              [links, html] -> %{preloadLinks: links, html: html}
              [html] -> %{preloadLinks: "", html: html}
            end

          body when is_map(body) ->
            body

          other ->
            Logger.error("unknown body response")
            other
        end
    end
  end

  defp telemetry_wrapped_render(mod, name, props, slots) do
    meta = %{component: name, props: props, slots: slots}

    :telemetry.span([:live_react, :ssr], meta, fn ->
      {mod.render(name, props, slots), meta}
    end)
  end
end

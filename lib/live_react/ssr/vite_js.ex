defmodule LiveReact.SSR.ViteJS do
  @moduledoc """
  Implements SSR by making a POST request to the Vite dev server's /ssr_render endpoint.
  """

  @behaviour LiveReact.SSR
  @impl true
  def render(name, props, slots) do
    data = Jason.encode!(%{name: name, props: props, slots: slots})
    url = vite_path("/ssr_render")
    params = {String.to_charlist(url), [], ~c"application/json", data}

    case :httpc.request(:post, params, [], []) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        %{html: :erlang.list_to_binary(body)}

      {:ok, {{_, 500, _}, _headers, body}} ->
        case Jason.decode(body) do
          {:ok, %{"error" => %{"message" => msg, "loc" => loc, "frame" => frame}}} ->
            %{
              error: %{
                message: msg,
                location: "#{loc["file"]}:#{loc["line"]}:#{loc["column"]}",
                frame: frame
              }
            }

          _ ->
            %{error: "Unexpected Vite SSR response: 500 #{body}"}
        end

      {:ok, {{_, status, code}, _headers, _body}} ->
        %{error: "Unexpected Vite SSR response: #{status} #{code}"}

      {:error, {:failed_connect, [{:to_address, {url, port}}, {_, _, code}]}} ->
        %{error: "Unable to connect to Vite #{url}:#{port}: #{code}"}
    end
  end

  @doc """
  Returns a path relative to the Vite dev server host.
  """
  def vite_path(path) do
    case Application.get_env(:tails, :vite_host) do
      nil ->
        message = """
        Vite.js host is not configured. Please add the following to config/dev.exs:

        config :tails, vite_host: "http://localhost:5173"

        and ensure vite.js is running
        """

        raise %LiveReact.SSR.NotConfigured{message: message}

      host ->
        Path.join(host, path)
    end
  end
end

defmodule TailsWeb.Otel.Resource do
  use Phoenix.Component

  def show(assigns) do
    # IO.inspect(assigns.messages)
    ~H"""
    <h1>
      resource
    </h1>
    """
  end
end

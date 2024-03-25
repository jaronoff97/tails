defmodule TailsWeb.Router do
  use TailsWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TailsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TailsWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", TailLive.Index, :index
  end

  scope "/dev" do
    pipe_through :browser

    live_dashboard "/dashboard", metrics: TailsWeb.Telemetry
  end

  if Application.compile_env(:tails, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
  end
end

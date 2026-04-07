defmodule Tails.MixProject do
  use Mix.Project

  def project do
    [
      app: :tails,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        # Put the project-level PLT in the priv/ directory (instead of the default _build/ location)
        plt_file: {:no_warn, "priv/plts/project.plt"},
        plt_add_apps: [:ex_unit]
      ],
      package: package()
    ]
  end

  defp package do
    [
      description:
        "A small application that allows you to tail the live telemetry of an otel collector",
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Jacob Aronoff"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/jaronoff97/tails"}
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Tails.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.21"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:floki, ">= 0.37.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.4"},
      {:protobuf, "~> 0.13.0"},
      {:bandit, "~> 1.6"},
      {:websockex, "~> 0.4.3"},
      {:uuid, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "npm.setup"],
      "npm.setup": ["cmd --cd assets npm install"],
      "assets.deploy": [
        "cmd --cd assets npm run build",
        "phx.digest"
      ]
    ]
  end
end

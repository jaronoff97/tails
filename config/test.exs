import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tails, TailsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "go9rSY5y8zjBI+y6EE9lxpfqQ7n6lJpkDWKtrfu88YyJYTAkcFgIgdKc1y8P9feP",
  server: false

# In test we don't send emails.
config :tails, Tails.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

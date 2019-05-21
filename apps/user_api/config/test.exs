use Mix.Config

config :user_api,
  secret: "2faf35cf63a83e392592aedbb2dae62e41e4bef5efccc15a679f212d2bdab27d40d4a4eba9be3a172438fb1b91cd6c503e0a2e1c59ce1e465b611a34d528b00f"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :user_api, UserApiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :error

import_config "#{Mix.env()}.secret.exs"

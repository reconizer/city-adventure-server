use Mix.Config
config :infrastructure, Infrastructure.Repository, pool: Ecto.Adapters.SQL.Sandbox
import_config "#{Mix.env()}.secret.exs"

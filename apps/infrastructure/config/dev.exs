use Mix.Config

config :logger, level: :info
config :infrastructure, :asset_bucket, ""
import_config("#{Mix.env()}.secret.exs")

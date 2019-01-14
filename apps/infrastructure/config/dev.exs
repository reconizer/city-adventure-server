use Mix.Config

config :logger, level: :debug
config :infrastructure, :asset_bucket, ""
import_config("#{Mix.env()}.secret.exs")

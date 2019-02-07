use Mix.Config

db_port = String.to_integer(System.get_env("CA_INFRASTRUCTURE_DATABASE_PORT"))

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("CA_INFRASTRUCTURE_DATABASE_USER"),
  password: System.get_env("CA_INFRASTRUCTURE_DATABASE_PASSWORD"),
  database: System.get_env("CA_INFRASTRUCTURE_DATABASE_NAME"),
  hostname: System.get_env("CA_INFRASTRUCTURE_DATABASE_HOST"),
  port: db_port,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes

config :infrastructure, :asset_bucket, System.get_env("CA_INFRASTRUCTURE_ASSET_BUCKET")

config :infrastructure, :google_client_id, System.get_env("CA_INFRASTRUCTURE_GOOGLE_CLIENT_ID")
config :infrastructure, :google_client_secret, System.get_env("CA_INFRASTRUCTURE_GOOGLE_CLIENT_SECRET")
config :infrastructure, :google_refresh_token, System.get_env("CA_INFRASTRUCTURE_GOOGLE_REFRESH_TOKEN")
config :infrastructure, :google_refresh_token_url, System.get_env("CA_INFRASTRUCTURE_GOOGLE_REFRESH_TOKEN_URL")
config :infrastructure, :google_play_api_url, System.get_env("CA_INFRASTRUCTURE_GOOGLE_PLAY_API_URL")

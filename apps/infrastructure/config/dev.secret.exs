use Mix.Config

config :infrastructure, Infrastructure.Repository,
  username: "developer",
  password: "developer",
  database: "gameinn_2",
  hostname: "localhost",
  port: 5433,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes

config :infrastructure, :asset_bucket, "gameinn-2-assets"

config :infrastructure, :google_client_id, "92449140121-i88btu39t89lt9da1hovh1e7ku39dbpq.apps.googleusercontent.com"
config :infrastructure, :google_client_secret, "8lOSIQYmS8_V8Dz7MSx26ygM"
config :infrastructure, :google_refresh_token, "1/xVyDNWgXNfiYujiU0TKqJFjz4qAKQ8CDlrHdobgz3UE"
config :infrastructure, :google_refresh_token_url, "https://accounts.google.com/o/oauth2/token"
config :infrastructure, :google_play_api_url, "https://www.googleapis.com"

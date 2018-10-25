use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "developer",
  password: "developer",
  database: "gameinn_2",
  hostname: "localhost",
  port: 5433,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes

config :infrastructure,
  asset_bucket: "assets-martin"

config :ex_aws, :s3,
  access_key_id: "AKIAJL6JC5RDYNQCFITA",
  secret_access_key: "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",
  region: "eu-west-1"
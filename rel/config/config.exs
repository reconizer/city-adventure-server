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

config :phoenix, :serve_endpoints, true

administration_api_port = String.to_integer(System.get_env("CA_ADMINISTRATION_API_PORT"))
user_api_port = String.to_integer(System.get_env("CA_USER_API_PORT"))
creator_api_port = String.to_integer(System.get_env("CA_CREATOR_API_PORT"))

config :administration_api, AdministrationApiWeb.Endpoint,
  http: [port: administration_api_port],
  url: [host: "localhost", port: administration_api_port]

config :creator_api, CreatorApiWeb.Endpoint,
  http: [port: creator_api_port],
  url: [host: "localhost", port: creator_api_port]

config :user_api, UserApiWeb.Endpoint,
  http: [port: user_api_port],
  url: [host: "localhost", port: user_api_port]

config :user_api,
  secret: System.get_env("CA_USER_API_SECRET")

config :user_api, CreatorApiWeb.Endpoint, secret_key_base: System.get_env("CA_USER_API_SECRET_KEY_BASE")

config :creator_api, CreatorApiWeb.Endpoint, secret_key_base: System.get_env("CA_CREATOR_API_SECRET_KEY_BASE")

config :administration_api, AdministrationApiWeb.Endpoint, secret_key_base: System.get_env("CA_ADMINITRATION_API_SECRET_KEY_BASE")

config :media_storage,
  s3_access_key_id: System.get_env("CA_MEDIA_STORAGE_S3_ACCESS_KEY_ID"),
  s3_secret_access_key: System.get_env("CA_MEDIA_STORAGE_S3_SECRET_ACCESS_KEY"),
  s3_region: System.get_env("CA_MEDIA_STORAGE_S3_REGION"),
  s3_bucket: System.get_env("CA_INFRASTRUCTURE_ASSET_BUCKET")

config :worker, :file_upload_queue_name, System.get_env("CA_WORKER_FILE_UPLOAD_QUEUE")
config :worker, :conversion_queue_name, System.get_env("CA_WORKER_CONVERSION_QUEUE")
config :worker, :asset_bucket, System.get_env("CA_INFRASTRUCTURE_ASSET_BUCKET")

config :ex_aws, :sqs,
  access_key_id: System.get_env("CA_EX_AWS_SQS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("CA_EX_AWS_SQS_SECRET_ACCESS_KEY"),
  region: System.get_env("CA_EX_AWS_SQS_REGION")

config :ex_aws, :s3,
  access_key_id: System.get_env("CA_EX_AWS_S3_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("CA_EX_AWS_S3_SECRET_ACCESS_KEY"),
  region: System.get_env("CA_EX_AWS_S3_REGION")

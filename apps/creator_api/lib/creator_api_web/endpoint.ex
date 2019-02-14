defmodule CreatorApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :creator_api

  socket("/socket", CreatorApiWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  plug(Corsica, origins: "*", allow_headers: :all, log: [rejected: :warn, invalid: :warn])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :creator_api,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(CreatorApiWeb.Plugs.AppName)
  plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session,
    store: :cookie,
    key: "_creator_api_key",
    signing_salt: "Bmwbw/jd"
  )

  plug(CreatorApiWeb.Router)
end

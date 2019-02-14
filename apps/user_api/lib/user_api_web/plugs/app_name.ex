defmodule UserApiWeb.Plugs.AppName do
  require Logger

  def init(arg), do: arg

  def call(conn, _default) do
    Logger.metadata(app: "user")

    conn
  end
end

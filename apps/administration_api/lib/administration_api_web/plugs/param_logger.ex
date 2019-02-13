defmodule AdministrationApiWeb.Plugs.ParamLogger do
  require Logger

  def init(arg), do: arg

  def call(conn, _default) do
    Logger.metadata(app: "AdministrationApi")

    Logger.info("Params: #{inspect(conn.params)}\n")

    conn
  end
end

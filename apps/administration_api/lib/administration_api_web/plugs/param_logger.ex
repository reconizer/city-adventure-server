defmodule AdministrationApiWeb.Plugs.ParamLogger do
  require Logger

  def init(arg), do: arg

  def call(conn, _default) do
    Logger.info("Params: #{inspect(conn.params)}")

    conn
  end
end

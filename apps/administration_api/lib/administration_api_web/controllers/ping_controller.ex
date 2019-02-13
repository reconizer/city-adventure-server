defmodule AdministrationApiWeb.PingController do
  use AdministrationApiWeb, :controller

  def ping(conn, _) do
    render(conn, "ping.json", %{})
  end
end

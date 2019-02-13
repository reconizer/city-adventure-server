defmodule AdministrationApiWeb.PingController do
  use AdministrationApiWeb, :silent_controller

  def ping(conn, _) do
    render(conn, "ping.json", %{})
  end
end

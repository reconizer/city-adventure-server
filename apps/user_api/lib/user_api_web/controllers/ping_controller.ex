defmodule UserApiWeb.PingController do
  use UserApiWeb, :silent_controller


  def ping(conn, _) do
    render(conn, "ping.json", %{})
  end

end
defmodule AdministrationApiWeb.Plugs.Token do
  import Plug.Conn

  def init(arg), do: arg

  def call(conn, _default) do
    conn
    |> get_req_header("authorization")
    |> case do
      [token] ->
        Phoenix.Token.verify(AdministrationApiWeb.Endpoint, "user salt", token, max_age: 86400)
        |> case do
          {:ok, administrator_id} ->
            conn
            |> assign(:administrator_id, administrator_id)

          _ ->
            conn
            |> unauthorize()
        end

      _ ->
        conn
        |> unauthorize()
    end
  end

  defp unauthorize(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> resp(401, Poison.encode!(%{}))
    |> halt()
  end
end

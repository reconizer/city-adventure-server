defmodule UserApiWeb.Plugs.Token do
  import Plug.Conn

  def init(arg), do: arg

  def call(conn, _default) do
    conn
    |> get_req_header("authorization")
    |> case do
      [token] ->
        Phoenix.Token.verify(UserApiWeb.Endpoint, "user salt", token, max_age: 86400)
        |> case do
          {:ok, user_id} ->
            conn
            |> assign(:user_id, user_id)

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

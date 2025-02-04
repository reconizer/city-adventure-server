defmodule UserApiWeb.ControllerHelpers do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def present(session, conn, view, action) do
    session
    |> case do
      %{valid?: true} ->
        conn
        |> Plug.Conn.put_status(200)
        |> Phoenix.Controller.put_view(view)
        |> Phoenix.Controller.render(action, %{session: session})

      %{context: %{"response_code" => code}, valid?: false} ->
        conn
        |> Plug.Conn.put_status(code)
        |> Phoenix.Controller.put_view(UserApiWeb.ErrorView)
        |> Phoenix.Controller.render("422.json", %{session: session})
      _ ->
        conn
        |> Plug.Conn.put_status(422)
        |> Phoenix.Controller.put_view(UserApiWeb.ErrorView)
        |> Phoenix.Controller.render("422.json", %{session: session})
    end
  end
end

defmodule UserApiWeb.Utils do
  import UserApiWeb.ErrorHandler

  def handle_repository_action(result, conn) do
    result
    |> case do
      {:ok, _} ->
        conn
        |> Phoenix.Controller.put_view(UserApiWeb.CommonView)
        |> Phoenix.Controller.render("empty.json")

      {:error, _, changeset, _} ->
        conn
        |> handle_error({:error, changeset})

      error ->
        conn
        |> handle_error(error)
    end
  end
end

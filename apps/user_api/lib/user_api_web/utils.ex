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

  def handle_errors(session, %Ecto.Changeset{} = changeset) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, _} ->
        msg
      end)

    session
    |> Session.add_error(errors)
  end

  def handle_errors(session, {error, message}) do
    handle_errors(session, %{error => message})
  end

  def handle_errors(session, errors) do
    session
    |> Session.add_error(errors)
  end

  def with_user(params, %{assigns: %{session: %{context: %{"current_user" => %{id: id}}}}}) do
    params
    |> Map.merge(%{"user_id" => id})
  end

  def with_user(params, _conn) do
    params
    |> Map.merge(%{"user_id" => nil})
  end
end

defmodule UserApiWeb.Utils do
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

  def with_user(params, conn) do
    params
    |> Map.merge(%{"user_id" => nil})
  end

end

defmodule CreatorApiWeb.Utils do
  def handle_errors(conn, %Ecto.Changeset{} = changeset) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, _} ->
        msg
      end)

    conn
    |> Plug.Conn.put_status(422)
    |> Phoenix.Controller.put_view(CreatorApiWeb.ErrorView)
    |> Phoenix.Controller.render("422.json", errors: errors)
  end

  def handle_errors(conn, {error, message}) do
    handle_errors(conn, %{error => message})
  end

  def handle_errors(conn, errors) do
    conn
    |> Plug.Conn.put_status(422)
    |> Phoenix.Controller.put_view(CreatorApiWeb.ErrorView)
    |> Phoenix.Controller.render("422.json", errors: errors)
  end

  def with_creator(params, conn) do
    creator_id = conn.assigns |> Map.get(:creator_id)

    params
    |> Map.merge(%{"creator_id" => creator_id})
  end

  def handle_repository_action(result, conn) do
    result
    |> case do
      {:ok, _} ->
        conn
        |> Phoenix.Controller.put_view(CreatorApiWeb.CommonView)
        |> Phoenix.Controller.render("empty.json")

      {:error, errors} ->
        conn
        |> handle_errors(errors)

      {:error, _, changeset, _} ->
        conn
        |> handle_errors(changeset)
    end
  end
end

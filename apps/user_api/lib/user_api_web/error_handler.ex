defmodule UserApiWeb.ErrorHandler do
  def handle_error(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, _} ->
        msg
      end)

    handle_error(conn, errors)
  end

  def handle_error(conn, {:error, errors}) when is_list(errors) do
    errors =
      errors
      |> Enum.map(fn
        {key, values} when is_list(values) -> {key, values}
        {key, value} -> {key, [value]}
      end)
      |> Enum.into(%{})

    handle_error(conn, errors)
  end

  def handle_error(conn, {:error, error}) do
    handle_error(conn, {:error, [error]})
  end

  def handle_error(conn, errors) do
    conn
    |> Plug.Conn.put_status(422)
    |> Phoenix.Controller.put_view(UserApiWeb.ErrorView)
    |> Phoenix.Controller.render("422.json", errors: errors)
  end
end

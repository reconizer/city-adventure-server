defmodule AdministrationApiWeb.ErrorHandler do
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
    |> Phoenix.Controller.put_view(AdministrationApiWeb.ErrorView)
    |> Phoenix.Controller.render("422.json", errors: errors)
  end

  # def handle_errors(conn, %Ecto.Changeset{} = changeset) do
  #   errors =
  #     changeset
  #     |> Ecto.Changeset.traverse_errors(fn {msg, _} ->
  #       msg
  #     end)

  #   conn
  #   |> Plug.Conn.put_status(422)
  #   |> Phoenix.Controller.put_view(AdministrationApiWeb.ErrorView)
  #   |> Phoenix.Controller.render("422.json", errors: errors)
  # end

  # def handle_errors(conn, {error, message}) do
  #   handle_errors(conn, %{error => message})
  # end

  # def handle_errors(conn, errors) do
  #   conn
  #   |> Plug.Conn.put_status(422)
  #   |> Phoenix.Controller.put_view(AdministrationApiWeb.ErrorView)
  #   |> Phoenix.Controller.render("422.json", errors: errors)
  # end

  # def handle_repository_action(result, conn) do
  #   result
  #   |> case do
  #     {:ok, _} ->
  #       conn
  #       |> Phoenix.Controller.put_view(AdministrationApiWeb.CommonView)
  #       |> Phoenix.Controller.render("empty.json")

  #     {:error, errors} ->
  #       conn
  #       |> handle_errors(errors)

  #     {:error, _, changeset, _} ->
  #       conn
  #       |> handle_errors(changeset)
  #   end
  # end
end

defmodule AdministrationApiWeb.Utils do
  import AdministrationApiWeb.ErrorHandler

  def handle_repository_action(result, conn) do
    result
    |> case do
      {:ok, _} ->
        conn
        |> Phoenix.Controller.put_view(AdministrationApiWeb.CommonView)
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

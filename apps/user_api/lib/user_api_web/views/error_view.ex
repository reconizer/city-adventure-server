defmodule UserApiWeb.ErrorView do
  use UserApiWeb, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("422.json", %{session: %Session{errors: errors}} = _session) do
    errors
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  defp render_error(key, {message, _valid}, acc) do
    key
    |> render_error(message, acc)
  end

  defp render_error(key, message, acc) do
    messages_to_add =
      cond do
        is_list(message) -> message
        true -> [message]
      end

    acc
    |> Map.get(key)
    |> case do
      nil ->
        acc |> Map.put(key, messages_to_add)

      error_messages ->
        acc |> Map.put(key, error_messages ++ messages_to_add)
    end
  end
end

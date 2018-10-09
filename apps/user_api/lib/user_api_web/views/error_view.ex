defmodule UserApiWeb.ErrorView do
  use UserApiWeb, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("422.json", %{session: %Session{errors: errors}} = session) do
    errors
    |> Enum.reduce(%{}, fn({key, list}, acc) ->
      key
      |> render_error(list, acc)
    end)
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

  defp render_error(key, {message, _valid}, acc) do
    acc
    |> Map.put(key, message)
  end
  
  defp render_error(key, message, acc) do
    acc 
    |> Map.put(key, message)
  end

end
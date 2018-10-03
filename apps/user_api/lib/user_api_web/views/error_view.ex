defmodule UserApiWeb.ErrorView do
  use UserApiWeb, :view

  def render("404.json", _assigns) do
    %{errors: %{detail: "Page not found"}}
  end

  def render("422.json", %{session: %Session{errors: errors}} = session) do
    errors 
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal server error"}}
  end

end
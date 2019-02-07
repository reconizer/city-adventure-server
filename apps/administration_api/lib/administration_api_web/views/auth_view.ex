defmodule AdministrationApiWeb.AuthView do
  use AdministrationApiWeb, :view

  def render("login.json", %{token: token}) do
    %{token: token}
  end
end

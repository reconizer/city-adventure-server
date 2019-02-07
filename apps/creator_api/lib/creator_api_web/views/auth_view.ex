defmodule CreatorApiWeb.AuthView do
  use CreatorApiWeb, :view

  def render("login.json", %{token: token}) do
    %{token: token}
  end
end

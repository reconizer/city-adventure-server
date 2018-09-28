defmodule UserApiWeb.AuthView do
  use UserApiWeb, :view

  def render("login.json", %Session{context: %{"jwt" => jwt}} = session) do
    %{
      jwt: jwt
    }
  end

end

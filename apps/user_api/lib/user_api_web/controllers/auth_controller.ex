defmodule UserApiWeb.AuthController do
  use UserApiWeb, :controller

  alias Domain.Profile.Repository.User, as: UserRepository
  alias Domain.Profile.Auth

  def login(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with {:ok, validate_params} <- Contract.User.Login.validate(context), 
      {:ok, user} <- UserRepository.get_by_email(validate_params.email), 
      {:ok, jwt} <- Auth.login(user, validate_params.password) 
    do
      session
      |> Session.update_context(%{"jwt" => jwt})
      |> present(conn, UserApiWeb.AuthView, "login.json")
    else
      {:error, reason} ->
        session 
        |> Session.add_error(reason)
        |> present(conn, UserApiWeb.AuthView, "login.json")
    end
    
  end

end
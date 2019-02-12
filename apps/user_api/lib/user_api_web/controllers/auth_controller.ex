defmodule UserApiWeb.AuthController do
  use UserApiWeb, :controller

  alias Domain.Profile.Repository.User, as: UserRepository
  alias Domain.Profile.Auth

  alias UserApiWeb.AuthContract
  alias Domain.Profile.Registration
  alias Domain.Profile.Repository.Registration, as: RegistrationRepository

  def login(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with {:ok, validate_params} <- Contract.User.Login.validate(context),
         {:ok, user} <- UserRepository.get_by_email(validate_params.email),
         {:ok, jwt} <- Auth.login(user, validate_params.password) do
      session
      |> Session.update_context(%{"jwt" => jwt})
    else
      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.AuthView, "login.json")
  end

  def register(conn, params) do
    with {:ok, params} <- AuthContract.register(conn, params),
         {:ok, user} <- Registration.new(params) do
      user
      |> RegistrationRepository.save()
      |> handle_repository_action(conn)
    else
      {:error, _} = error -> conn |> handle_error(error)
    end
  end
end

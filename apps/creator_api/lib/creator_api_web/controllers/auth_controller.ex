defmodule CreatorApiWeb.AuthController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.AuthContract
  alias Domain.Creator

  def login(conn, params) do
    AuthContract.login(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Repository.User.get_by_email_and_password(params.email, params.password)
        |> case do
          {:ok, user} ->
            token = CreatorApi.Token.create(user.id)

            conn
            |> render("login.json", %{token: token})

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def register(conn, params) do
    AuthContract.register(conn, params)
    |> case do
      {:ok, params} ->
        Creator.User.new(
          %{
            email: params.email,
            name: params.name
          },
          params.password
        )
        |> case do
          {:ok, user} ->
            Creator.Repository.User.save(user)
            |> handle_repository_action(conn)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def logout(conn, params) do
    AuthContract.logout(conn, params)
  end
end

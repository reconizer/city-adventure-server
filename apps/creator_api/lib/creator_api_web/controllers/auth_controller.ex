defmodule CreatorApiWeb.AuthController do
  use CreatorApiWeb, :controller

  import Contract

  def login(conn, params) do
    params
    |> cast(%{
      email: :string,
      password: :string
    })
    |> validate(%{
      email: :required,
      password: :required
    })
    |> case do
      {:ok, params} ->
        Domain.Creator.Repository.User.get_by_email_and_password(params.email, params.password)
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
    params
    |> cast(%{
      email: :string,
      password: :string,
      name: :string
    })
    |> validate(%{
      email: :required,
      password: :required,
      name: :required
    })
    |> case do
      {:ok, params} ->
        Domain.Creator.User.new(
          %{
            email: params.email,
            name: params.name
          },
          params.password
        )
        |> case do
          {:ok, user} ->
            Domain.Creator.Repository.User.save(user)
            |> handle_repository_action(conn)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def logout(conn, params) do
  end
end

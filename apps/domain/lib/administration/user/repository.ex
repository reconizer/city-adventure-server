defmodule Domain.Administration.User.Repository do
  use Domain.Repository

  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models

  alias Domain.Administration.User

  @type authentication_params :: %{required(:email) => String.t(), required(:password) => String.t()}
  @type error :: {:error, any()}

  @spec get(Ecto.UUID.t()) :: User.entity()
  def get(id) do
    Models.Administrator
    |> Repository.get(id)
    |> build_administrator
  end

  @spec get_for_authentication(authentication_params | {:ok, authentication_params} | error) :: User.entity()
  def get_for_authentication({:ok, params}), do: get_for_authentication(params)
  def get_for_authentication({:error, _} = error), do: error

  def get_for_authentication(%{email: email, password: password}) do
    Models.Administrator
    |> Repository.get_by(email: email)
    |> case do
      nil ->
        {:error, {:email, "user not found"}}

      user ->
        cond do
          Comeonin.Bcrypt.checkpw(password, user.password_digest) ->
            {:ok, user |> build_administrator}

          true ->
            {:error, {:password, "invalid password"}}
        end
    end
  end

  @spec build_administrator(nil | Models.Administrator.t()) :: User.entity()
  def build_administrator(nil), do: {:error, "doesnt exist"}

  def build_administrator(administrator_model) do
    %User{
      id: administrator_model.id,
      email: administrator_model.email,
      name: administrator_model.name
    }
  end
end

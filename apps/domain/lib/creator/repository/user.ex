defmodule Domain.Creator.Repository.User do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.Creator

  def get(id) do
    Models.Creator
    |> preload([:adventures])
    |> Repository.get(id)
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user |> build_creator}
    end
  end

  def get!(id) do
    get(id)
    |> case do
      {:ok, user} -> user
    end
  end

  def get_by_email_and_password(email, password) do
    Models.Creator
    |> where([creator], ilike(creator.email, ^email))
    |> preload([:adventures])
    |> Repository.one()
    |> case do
      nil ->
        {:error, %{email: ["user not found"]}}

      user ->
        cond do
          Comeonin.Bcrypt.checkpw(password, user.password_digest) ->
            {:ok, user |> build_creator}

          true ->
            {:error, %{password: ["invalid password"]}}
        end
    end
  end

  defp build_creator(creator_model) do
    %Creator.User{
      id: creator_model.id,
      name: creator_model.name,
      email: creator_model.email,
      adventures: creator_model.adventures |> Enum.map(&build_adventure/1)
    }
  end

  def build_adventure(adventure_model) do
    %Creator.User.Adventure{
      id: adventure_model.id
    }
  end
end

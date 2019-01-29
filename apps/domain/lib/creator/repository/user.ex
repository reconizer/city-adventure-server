defmodule Domain.Creator.Repository.User do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.Creator

  def get(id) do
    Models.Creator
    |> join(:left, [creator], adventures in assoc(creator, :adventures))
    |> join(:left, [creator, adventures], asset in assoc(adventures, :asset))
    |> join(:left, [creator, adventures, asset], rating in assoc(adventures, :creator_adventure_rating))
    |> join(:left, [creator, adventures, asset, rating], images in assoc(adventures, :images))
    |> preload([creator, adventures, asset, rating, images], [adventures: {adventures, [asset: asset, creator_adventure_rating: rating, images: images]}])
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
    |> join(:left, [creator], adventures in assoc(creator, :adventures))
    |> join(:left, [creator, adventures], asset in assoc(adventures, :asset))
    |> join(:left, [creator, adventures, asset], rating in assoc(adventures, :creator_adventure_rating))
    |> join(:left, [creator, adventures, asset, rating], images in assoc(adventures, :images))
    |> where([creator, adventures, asset, rating, images], ilike(creator.email, ^email))
    |> preload([creator, adventures, asset, rating, images], [adventures: {adventures, [asset: asset, creator_adventure_rating: rating, images: images]}])
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

  defp build_adventure(adventure_model) do
    %Creator.User.Adventure{
      id: adventure_model.id,
      name: adventure_model.name,
      show: adventure_model.show,
      status: adventure_model.status,
      rating: adventure_model.creator_adventure_rating |> adventure_rating(),
      asset: adventure_model.asset |> build_asset()
    }
  end

  defp build_asset(nil), do: nil
  defp build_asset(asset_model) do
    %Creator.User.Asset{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension
    }
  end

  
  defp adventure_rating(nil), do: nil
  defp adventure_rating(%{rating: rating}) do
    rating
  end

end

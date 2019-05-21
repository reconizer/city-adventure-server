defmodule Domain.Profile.Repository.User do
  import Ecto.Query
  alias Infrastructure.Repository
  use Infrastructure.Repository.Models
  use Domain.Repository

  alias Domain.Profile.{
    Profile,
    Avatar,
    Asset,
    CreatorFollower
  }

  def get_by_email(email) do
    from(u in Models.User,
      where: u.email == ^email
    )
    |> Repository.one()
    |> case do
      nil -> {:error, {:base, "not_found"}}
      result -> {:ok, result}
    end
  end

  def get_by_id(%{user_id: id}) do
    Models.User
    |> preload(avatar: :asset)
    |> preload(:creator_followers)
    |> Repository.get(id)
    |> case do
      nil -> {:error, {:base, "not_found"}}
      result -> {:ok, result |> load_user()}
    end
  end

  def get_by_id(id) do
    Models.User
    |> Repository.get(id)
    |> case do
      nil -> {:error, {:base, "not_found"}}
      result -> {:ok, result}
    end
  end

  defp load_user(%Models.User{} = user_model) do
    %Profile{
      id: user_model.id,
      nick: user_model.nick,
      email: user_model.email,
      avatar: user_model.avatar |> load_avatar(),
      creator_followers: user_model.creator_followers |> Enum.map(&load_follower/1)
    }
  end

  defp load_avatar(%Models.Avatar{} = avatar_model) do
    %Avatar{
      user_id: avatar_model.user_id,
      asset: avatar_model.asset |> load_asset()
    }
  end

  defp load_asset(%Models.Asset{} = asset_model) do
    %Asset{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension
    }
  end

  defp load_follower(%Models.CreatorFollower{} = creator_follower_model) do
    %CreatorFollower{
      user_id: creator_follower_model.user_id,
      creator_id: creator_follower_model.creator_id
    }
  end
end

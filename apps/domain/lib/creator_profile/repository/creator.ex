defmodule Domain.CreatorProfile.Repository.Creator do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.CreatorProfile.{
    Creator,
    Asset
  }

  def get(id) do
    Models.Creator
    |> preload(:asset)
    |> preload(:creator_followers)
    |> Repository.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user |> build_creator}
    end
  end

  defp build_creator(creator_model) do
    %Creator{
      id: creator_model.id,
      name: creator_model.name,
      followers_count: creator_model.creator_followers |> count_followers(),
      description: creator_model.description,
      asset: creator_model.asset |> build_asset()
    }
  end

  defp build_asset(nil), do: nil

  defp build_asset(asset_model) do
    %Asset{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension
    }
  end

  defp count_followers(followers) when is_list(followers) do
    Enum.count(followers)
  end

  defp count_followers(_), do: 0
end

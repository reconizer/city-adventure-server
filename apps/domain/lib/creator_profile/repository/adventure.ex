defmodule Domain.CreatorProfile.Repository.Adventure do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.CreatorProfile.{
    Adventure,
    Asset
  }

  def get_by_creator_id(creator_id) do
    Models.Adventure
    |> join(:left, [adventure], asset in assoc(adventure, :asset))
    |> join(:left, [adventure, asset], creator_rating in assoc(adventure, :creator_adventure_rating))
    |> where([adventure, asset, creator_rating], adventure.creator_id == ^creator_id)
    |> where([adventure, asset, creator_rating], adventure.published == true)
    |> preload([adventure, asset, creator_rating], asset: asset)
    |> preload([adventure, asset, creator_rating], creator_adventure_rating: creator_rating)
    |> Repository.all()
    |> Enum.map(&build_adventure/1)
  end

  defp build_adventure(adventure_model) do
    %Adventure{
      id: adventure_model.id,
      difficulty_level: adventure_model.difficulty_level,
      min_time: adventure_model.min_time,
      max_time: adventure_model.max_time,
      rating: adventure_model.creator_adventure_rating |> get_rating(),
      asset: adventure_model.asset |> build_asset
    }
  end

  defp get_rating(model_rating) do
    model_rating
    |> Map.get(:rating)
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
end

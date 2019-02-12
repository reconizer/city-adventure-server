defmodule Domain.UserAdventure.Service.Ranking do
  @moduledoc """
  Service load rankings for adventure
  """
  use Infrastructure.Repository.Models
  use Domain.Repository
  import Ecto.Query
  alias Infrastructure.Repository
  alias Domain.UserAdventure.Adventure

  def get_rankings_adventure(%Adventure{} = adventure, %{page: page, limit: limit}) do
    rankings =
      get_rankings(adventure.id)
      |> applay_pagination(page, limit)
      |> Repository.all()
      |> Enum.map(&load_ranking/1)

    {:ok, rankings}
  end

  def top_five(%Adventure{} = adventure) do
    rankings =
      get_rankings(adventure.id)
      |> limit(5)
      |> Repository.all()
      |> Enum.map(&load_ranking/1)

    {:ok, rankings}
  end

  def top_ten(%Adventure{} = adventure) do
    rankings =
      get_rankings(adventure.id)
      |> limit(10)
      |> Repository.all()
      |> Enum.map(&load_ranking/1)

    {:ok, rankings}
  end

  defp get_rankings(id) do
    Models.UserRanking
    |> where([user_rankings], user_rankings.adventure_id == ^id)
    |> preload([user_ranking], :asset)
  end

  defp applay_pagination(query, page, limit) do
    query
    |> limit(^limit)
    |> offset(^((page - 1) * limit))
  end

  defp load_ranking(%Models.UserRanking{} = ranking_model) do
    %{
      user_id: ranking_model.user_id,
      adventure_id: ranking_model.adventure_id,
      position: ranking_model.position,
      nick: ranking_model.nick,
      completion_time: ranking_model.completion_time,
      asset: ranking_model.asset |> load_asset()
    }
  end

  defp load_asset(%Models.Asset{} = asset_model) do
    %{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension
    }
  end
end

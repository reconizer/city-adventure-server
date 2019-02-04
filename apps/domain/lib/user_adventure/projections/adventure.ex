defmodule Domain.UserAdventure.Projections.Adventure do
  @moduledoc """
  Projection of adventure information
  """

  @type t :: %__MODULE__{}

  defstruct [
    :id,
    :description,
    :min_time,
    :max_time,
    :difficulty_level,
    :language,
    :name,
    :rating_count,
    :creator_id,
    :rating,
    :author_name,
    :author_id,
    :owner_rating,
    author_asset: %{},
    owner_ranking: %{},
    asset: %{},
    images: [],
    top_five: []
  ]

  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Domain.UserAdventure.Projections.Adventure
  alias Infrastructure.Repository

  def get_adventure_by_id(%{id: adventure_id, user_id: owner_id}) do
    from(adventure in Models.Adventure,
      left_join: asset in assoc(adventure, :asset),
      preload: [asset: asset],
      where: adventure.id == ^adventure_id,
      where: adventure.show == true and adventure.published == true
    )
    |> Repository.one()
    |> case do
      nil ->
        {:error, {:adventure, "not_found"}}

      result ->
        %Adventure{
          id: result.id,
          name: result.name,
          creator_id: result.creator_id,
          description: result.description,
          min_time: result.min_time |> parse_time_to_seconds(),
          max_time: result.max_time |> parse_time_to_seconds(),
          difficulty_level: result.difficulty_level,
          language: result.language,
          asset: result.asset
        }
        |> get_rating()
        |> get_owner_rating(owner_id)
        |> get_assets()
        |> get_ranking()
        |> get_owner_ranking(owner_id)
        |> get_creator()
    end
  end

  defp get_assets(%Adventure{} = adventure) do
    from(image in Models.Image,
      left_join: asset in assoc(image, :asset),
      preload: [asset: asset],
      where: image.adventure_id == ^adventure.id
    )
    |> Repository.all()
    |> case do
      nil ->
        adventure

      result ->
        adventure
        |> Map.put(:images, result)
    end
  end

  defp get_owner_rating(%Adventure{} = adventure, owner_id) do
    from(rating in Models.AdventureRating,
      where: rating.adventure_id == ^adventure.id,
      where: rating.user_id == ^owner_id
    )
    |> Repository.one()
    |> case do
      nil ->
        adventure

      result ->
        adventure
        |> Map.put(:owner_rating, result.rating)
    end
  end

  defp get_rating(%Adventure{} = adventure) do
    from(rating in Models.AdventureRating,
      select: %{
        rating_count: count(rating.user_id),
        rating: avg(rating.rating)
      },
      where: rating.adventure_id == ^adventure.id
    )
    |> Repository.one()
    |> case do
      nil ->
        adventure

      result ->
        adventure
        |> Map.put(:rating_count, result.rating_count)
        |> Map.put(:rating, result.rating)
    end
  end

  defp get_creator(%Adventure{} = adventure) do
    from(creator in Models.Creator,
      left_join: asset in assoc(creator, :asset),
      preload: [asset: asset],
      where: creator.id == ^adventure.creator_id
    )
    |> Repository.one()
    |> case do
      nil ->
        {:error, {:creator, "not_found"}}

      result ->
        adventure_update =
          adventure
          |> Map.put(:author_name, result.name)
          |> Map.put(:author_id, result.id)
          |> Map.put(:author_asset, result.asset)

        {:ok, adventure_update}
    end
  end

  defp get_ranking(%Adventure{} = adventure) do
    from(ranking in Models.UserRanking,
      join: user in assoc(ranking, :user),
      left_join: avatar in assoc(user, :avatar),
      left_join: asset in assoc(avatar, :asset),
      preload: [asset: asset],
      where: ranking.adventure_id == ^adventure.id,
      limit: 5
    )
    |> Repository.all()
    |> case do
      [] ->
        adventure

      result ->
        adventure
        |> Map.put(:top_five, result)
    end
  end

  defp get_owner_ranking(%Adventure{} = adventure, owner_id) do
    from(ranking in Models.UserRanking,
      join: user in assoc(ranking, :user),
      left_join: avatar in assoc(user, :avatar),
      left_join: asset in assoc(avatar, :asset),
      preload: [asset: asset],
      where: ranking.adventure_id == ^adventure.id,
      where: ranking.user_id == ^owner_id
    )
    |> Repository.one()
    |> case do
      [] ->
        adventure

      result ->
        adventure
        |> Map.put(:owner_ranking, result)
    end
  end

  defp parse_time_to_seconds(nil), do: nil

  defp parse_time_to_seconds(minute) do
    minute / 60
  end
end

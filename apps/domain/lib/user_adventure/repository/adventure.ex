defmodule Domain.UserAdventure.Repository.Adventure do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  use Domain.Repository
  import Ecto.Query
  alias Infrastructure.Repository
  alias Domain.UserAdventure.Adventure

  alias Domain.UserAdventure.Adventure.{
    Point,
    Answer,
    Clue,
    UserPoint,
    UserRanking,
    AdventureRating,
    UserAdventure,
    AssetConversion,
    Asset,
    Image,
    Creator
  }

  def get(%{adventure_id: adventure_id, user_id: user_id}) do
    Models.Adventure
    |> join(:left, [adventure], points in assoc(adventure, :points))
    |> join(:left, [adventure, points], user_rankings in assoc(adventure, :user_rankings), on: user_rankings.user_id == ^user_id)
    |> join(:left, [adventure, points, user_rankings], user_points in assoc(points, :user_points), on: user_points.user_id == ^user_id)
    |> join(:left, [adventure, points, user_rankings, user_points], user_adventures in assoc(adventure, :user_adventures),
      on: user_adventures.user_id == ^user_id
    )
    |> join(:left, [adventure, points, user_rankings, user_points, user_adventures], user_rating in assoc(adventure, :adventure_ratings),
      on: user_rating.user_id == ^user_id
    )
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], user_points: user_points)
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], user_adventures: user_adventures)
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], adventure_ratings: user_rating)
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], user_rankings: {user_rankings, :asset})
    |> preload(creator: :asset)
    |> preload(images: :asset)
    |> preload(:asset)
    |> preload(points: [clues: [asset: :asset_conversions]])
    |> preload(points: :answers)
    |> Repository.get(adventure_id)
    |> case do
      nil -> {:error, {:adventure, "not_found"}}
      result -> {:ok, result |> load_adventure()}
    end
  end

  def user_list(%{user_id: user_id, filter: %{filters: filters} = option}) do
    result =
      Models.Adventure
      |> join(:left, [adventure], user_rankings in assoc(adventure, :user_rankings), on: user_rankings.user_id == ^user_id)
      |> join(:inner, [adventure, user_rankings], user_adventures in assoc(adventure, :user_adventures))
      |> join(:left, [adventure, user_rankings, user_adventures], user_rating in assoc(adventure, :adventure_ratings))
      |> preload([adventure, user_rankings, user_adventures, user_rating], user_adventures: user_adventures)
      |> preload([adventure, user_rankings, user_adventures, user_rating], adventure_ratings: user_rating)
      |> preload([adventure, user_rankings, user_adventures, user_rating], user_rankings: user_rankings)
      |> preload(creator: :asset)
      |> preload(:asset)
      |> where([adventure, user_rankings, user_adventures, user_rating], user_adventures.user_id == ^user_id)
      |> filter_adventure(filters)
      |> paginate(option)
      |> Repository.all()
      |> Enum.map(&load_adventure/1)

    {:ok, result}
  end

  def load_adventure(%Models.Adventure{} = model) do
    %Adventure{
      id: model.id,
      name: model.name,
      creator_id: model.creator_id,
      description: model.description,
      min_time: model.min_time,
      max_time: model.max_time,
      completed: model.user_adventures |> set_completed(),
      creator: model.creator |> load_creator(),
      difficulty_level: model.difficulty_level,
      language: model.language,
      user_ranking: model.user_rankings |> List.first() |> load_user_ranking(),
      user_rating: model.adventure_ratings |> List.first() |> load_user_rating(),
      asset: model.asset |> load_asset(),
      images: model.images |> enum_load_images(),
      points: model.points |> enum_load_points(),
      user_adventure: model.user_adventures |> List.first() |> load_user_adventure(),
      user_points: model.user_points |> enum_load_user_points()
    }
  end

  def load_creator(%Models.Creator{} = creator_model) do
    %Creator{
      id: creator_model.id,
      name: creator_model.name,
      asset: creator_model.asset |> load_asset()
    }
  end

  def load_points(%Models.Point{} = point) do
    %Point{
      id: point.id,
      position: point.position,
      show: point.show,
      radius: point.radius,
      inserted_at: point.inserted_at,
      parent_point_id: point.parent_point_id,
      adventure_id: point.adventure_id,
      answers: point.answers |> Enum.map(&load_answers/1),
      clues: point.clues |> Enum.map(&load_clues/1)
    }
  end

  def enum_load_points(points) when is_list(points) do
    points
    |> Enum.map(&load_points/1)
  end

  def enum_load_points(_points), do: []

  def load_answers(%Models.Answer{} = answer) do
    %Answer{
      type: answer.type,
      details: answer.details,
      point_id: answer.point_id,
      id: answer.id
    }
  end

  def load_clues(%Models.Clue{} = clue) do
    %Clue{
      description: clue.description,
      type: clue.type,
      tip: clue.tip,
      sort: clue.sort,
      url: clue.url,
      point_id: clue.point_id,
      asset_id: clue.asset_id,
      id: clue.id,
      asset: clue.asset |> load_asset()
    }
  end

  def find_user_ranking(user_rankings, user_id) do
    user_rankings
    |> Enum.find(fn ranking ->
      ranking.user_id == user_id
    end)
  end

  def find_user_rating(user_ratings, user_id) do
    user_ratings
    |> Enum.find(fn rating ->
      rating.user_id == user_id
    end)
  end

  def load_user_rating(%Models.AdventureRating{} = user_rating) do
    %AdventureRating{
      user_id: user_rating.user_id,
      adventure_id: user_rating.adventure_id,
      rating: user_rating.rating
    }
  end

  def load_user_rating(_), do: nil

  def load_user_points(%Models.UserPoint{} = user_point) do
    %UserPoint{
      position: user_point.position,
      completed: user_point.completed,
      user_id: user_point.user_id,
      point_id: user_point.point_id,
      inserted_at: user_point.inserted_at,
      updated_at: user_point.updated_at
    }
  end

  def enum_load_user_points(user_points) when is_list(user_points) do
    user_points |> Enum.map(&load_user_points/1)
  end

  def enum_load_user_points(_), do: []

  defp load_image(%Models.Image{} = image_model) do
    %Image{
      id: image_model.id,
      sort: image_model.sort,
      asset: image_model.asset |> load_asset()
    }
  end

  defp enum_load_images(images) when is_list(images) do
    images |> Enum.map(&load_image/1)
  end

  defp enum_load_images(_), do: []

  defp set_completed(user_adventures) do
    user_adventures
    |> List.first()
    |> case do
      nil ->
        false

      result ->
        result
        |> Map.get(:completed)
    end
  end

  defp load_asset(%Models.Asset{} = asset_model) do
    %Asset{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension,
      asset_conversions: asset_model.asset_conversions
    }
  end

  defp load_asset(_), do: nil

  def build_asset_conversions(%Models.AssetConversion{} = asset_conversion_models) do
    asset_conversion_models
    |> Enum.map(fn conversion_model ->
      %AssetConversion{
        id: conversion_model.id,
        type: conversion_model.type,
        name: conversion_model.name,
        extension: conversion_model.extension,
        asset_id: conversion_model.asset_id
      }
    end)
  end

  def build_asset_conversions(_), do: []

  defp load_user_ranking(%Models.UserRanking{} = ranking_model) do
    %UserRanking{
      user_id: ranking_model.user_id,
      adventure_id: ranking_model.adventure_id,
      position: ranking_model.position,
      nick: ranking_model.nick,
      completion_time: ranking_model.completion_time,
      asset: ranking_model.asset |> load_asset()
    }
  end

  defp load_user_ranking(_), do: nil

  def load_user_adventure(nil), do: nil

  def load_user_adventure(user_adventure) do
    %UserAdventure{
      completed: user_adventure.completed,
      user_id: user_adventure.user_id,
      adventure_id: user_adventure.adventure_id
    }
  end

  defp filter_adventure(query, %{completed: completed}) do
    query
    |> where([adventure, user_rankings, user_adventures, user_rating], user_adventures.completed == ^completed)
  end

  defp filter_adventure(query, %{paid: true}) do
    query
  end

  defp filter_adventure(query, _) do
    query
  end
end

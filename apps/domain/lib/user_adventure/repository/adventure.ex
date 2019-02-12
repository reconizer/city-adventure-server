defmodule Domain.UserAdventure.Repository.Adventure do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  use Domain.Repository
  import Ecto.Query
  alias Infrastructure.Repository
  alias Ecto.Multi
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
    |> join(:left, [adventure, points, user_rankings, user_points], user_adventures in assoc(adventure, :user_adventures))
    |> join(:left, [adventure, points, user_rankings, user_points, user_adventures], user_rating in assoc(adventure, :adventure_ratings),
      on: user_rating.user_id == ^user_id
    )
    |> where([_adventure, _points, _user_rankings, _user_points, user_adventures, user_rating], user_adventures.user_id == ^user_id)
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], user_points: user_points)
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], user_adventures: user_adventures)
    |> preload([adventure, points, user_rankings, user_points, user_adventures, user_rating], adventure_ratings: user_rating)
    |> preload(user_rankings: :asset)
    |> preload(creator: :asset)
    |> preload(images: :asset)
    |> preload(:asset)
    |> preload(points: [clues: [asset: :asset_conversions]])
    |> preload(points: :answers)
    |> Repository.get(adventure_id)
    |> case do
      nil -> {:error, {:adventure, "not_founds"}}
      result -> {:ok, result |> load_adventure(user_id)}
    end
  end

  def start_adventure(%{adventure_id: adventure_id, user_id: id} = params) do
    Multi.new()
    |> Multi.run(:start_point, fn _, _ -> get_start_point(adventure_id) end)
    |> Multi.insert(:user_adventure, params |> build_user_adventure(), returning: true)
    |> Multi.merge(fn %{start_point: start_point} ->
      Multi.new()
      |> Multi.insert(:user_point, build_user_point(start_point, id))
    end)
    |> Infrastructure.Repository.transaction()
  end

  def build_user_point(point, user_id) do
    %{
      point_id: point.id,
      user_id: user_id,
      completed: true
    }
    |> Models.UserPoint.build()
  end

  def complete_adventure(adventure) do
    adventure
    |> Ecto.Changeset.change(%{completed: true})
    |> Repository.update()
  end

  defp build_user_adventure(%{adventure_id: id, user_id: user_id}) do
    %{
      adventure_id: id,
      user_id: user_id,
      completed: false
    }
    |> Models.UserAdventure.build()
  end

  defp get_start_point(adventure_id) do
    from(point in Models.Point,
      where: is_nil(point.parent_point_id),
      where: point.adventure_id == ^adventure_id
    )
    |> Repository.one()
    |> case do
      nil -> {:error, :point_not_found}
      result -> {:ok, result}
    end
  end

  def load_adventure(%Models.Adventure{} = model, user_id) do
    %Adventure{
      id: model.id,
      name: model.name,
      creator_id: model.creator_id,
      description: model.description,
      min_time: model.min_time,
      max_time: model.max_time,
      creator: model.creator |> load_creator(),
      difficulty_level: model.difficulty_level,
      language: model.language,
      user_ranking: model.user_rankings |> find_user_ranking(user_id) |> load_user_ranking(),
      user_rating: model.adventure_ratings |> List.first() |> load_user_rating(),
      asset: model.asset |> load_asset(),
      images: model.images |> Enum.map(&load_image/1),
      points: model.points |> Enum.map(&load_points/1),
      user_adventure: model.user_adventures |> List.first() |> load_user_adventure(),
      user_points: model.user_points |> Enum.map(&load_user_points/1)
    }
  end

  def load_creator(%Models.Creator{} = creator_model) do
    %Creator{
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

  defp load_image(%Models.Image{} = image_model) do
    %Image{
      id: image_model.id,
      sort: image_model.sort,
      asset: image_model.asset |> load_asset()
    }
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

  def load_user_adventure(nil), do: nil

  def load_user_adventure(user_adventure) do
    %UserAdventure{
      completed: user_adventure.completed,
      user_id: user_adventure.user_id,
      adventure_id: user_adventure.adventure_id
    }
  end
end

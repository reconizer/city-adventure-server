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
    UserAdventure
  }

  def get(%{adventure_id: adventure_id, user_id: user_id}) do
    Models.Adventure
    |> join(:left, [adventure], points in assoc(adventure, :points))
    |> join(:left, [adventure, points], user_points in assoc(points, :user_points), on: user_points.user_id == ^user_id)
    |> join(:left, [adventure, points, user_points], user_adventures in assoc(adventure, :user_adventures))
    |> where([adventure, points, user_points, user_adventures], user_adventures.user_id == ^user_id)
    |> preload([adventure, points, user_points, user_adventures], user_points: user_points)
    |> preload([adventure, points, user_points, user_adventures], user_adventures: user_adventures)
    |> preload(points: :clues)
    |> preload(points: :answers)
    |> Repository.get(adventure_id)
    |> case do
      nil -> {:error, {:adventure, "not_founds"}}
      result -> {:ok, result |> load_adventure()}
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

  def load_adventure(model) do
    %Adventure{
      id: model.id,
      points: model.points |> Enum.map(&load_points/1),
      user_adventure: model.user_adventures |> List.first() |> load_user_adventure(),
      user_points: model.user_points |> Enum.map(&load_user_points/1)
    }
  end

  def load_points(point) do
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

  def load_answers(answer) do
    %Answer{
      type: answer.type,
      details: answer.details,
      point_id: answer.point_id,
      id: answer.id
    }
  end

  def load_clues(clue) do
    %Clue{
      description: clue.description,
      type: clue.type,
      tip: clue.tip,
      sort: clue.sort,
      point_id: clue.point_id,
      asset_id: clue.asset_id,
      id: clue.id
    }
  end

  def load_user_points(user_point) do
    %UserPoint{
      position: user_point.position,
      completed: user_point.completed,
      user_id: user_point.user_id,
      point_id: user_point.point_id,
      inserted_at: user_point.inserted_at,
      updated_at: user_point.updated_at
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

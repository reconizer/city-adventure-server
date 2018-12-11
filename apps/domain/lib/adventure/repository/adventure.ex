defmodule Domain.Adventure.Repository.Adventure do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Infrastructure.Repository
  alias Ecto.Multi
  alias Domain.Adventure.{
    Adventure,
    Point,
    Answer,
    Clue
  }

  def get(adventure_id) do
    Models.Adventure
    |> preload(:points)
    |> preload([points: :clues])
    |> preload([points: :answers])
    |> Repository.get(adventure_id)
    |> load_adventure()
  end

  def get_user_points(adventure, %{id: user_id}) do
    user_points = from(user_point in Models.UserPoint,
      join: point in Models.Point, on: [id: user_point.point_id],
      join: user in Models.User, on: [id: user_point.user_id],
      where: point.adventure_id == ^adventure.id,
      where: user.id == ^user_id
    )
    |> Repository.all()
    %{adventure | user_points: user_points}
  end

  def start_adventure(%{adventure_id: adventure_id} = params, %Contract.User.Profile{id: id}) do
    Multi.new()
    |> Multi.run(:start_point, fn _ -> get_start_point(adventure_id) end)
    |> Multi.insert(:user_adventure, build_user_adventure(params, id), returning: true)
    |> Multi.merge(fn %{start_point: start_point} ->
      Multi.new
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

  # defp parse_event(%Complete{} = event, multi) do
  #   multi
  #   |> Ecto.Multi.update(:update_adventure, %Models.Adventure{id: event.id} |> Models.Adventure.changeset(%{
  #     completed: event.completed
  #   }), force: true)
  # end

  defp build_user_adventure(%{adventure_id: id}, user_id) do
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

  def load_adventure(nil), do: nil
  def load_adventure(model) do
    %Adventure{
      id: model.id,
      name: model.name,
      description: model.description,
      min_time: model.min_time,
      max_time: model.max_time,
      difficulty_level: model.difficulty_level,
      language: model.language,
      points: model.points |> Enum.map(&load_points/1)
    }
  end

  def load_points(point) do
    %Point{
      id: point.id,
      position: point.position,
      show: point.show, 
      radius: point.radius,
      parent_point_id: point.parent_point_id,
      adventure_id: point.adventure_id,
      answers: point.answers |> Enum.map(&load_answers/1),
      clues: point.clues |> Enum.map(&load_clues/1)
    }
  end

  def load_answers(answer) do
    %Answer{
      sort: answer.sort,
      type:  answer.type,
      details: answer.details,
      point_id:  answer.point_id,
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
    %UserPoints{
      position: user_point.position,
      completed: user_point.completed,
      user_id: user_point.user_id,
      point_id: user_point.point_id
    }
  end

end
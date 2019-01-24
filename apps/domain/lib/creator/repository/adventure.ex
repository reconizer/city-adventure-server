defmodule Domain.Creator.Repository.Adventure do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.Creator

  def get(id) do
    Models.Adventure
    |> preload(points: [:answers, :clues])
    |> Repository.get(id)
    |> case do
      nil -> {:error, :not_found}
      adventure -> {:ok, adventure |> build_adventure}
    end
  end

  def get!(id) do
    get(id)
    |> case do
      {:ok, adventure} -> adventure
    end
  end

  defp build_adventure(adventure_model) do
    %Creator.Adventure{
      id: adventure_model.id,
      name: adventure_model.name,
      creator_id: adventure_model.creator_id
    }
    |> Creator.Adventure.set_points(Enum.map(adventure_model.points, &build_point/1))
    |> case do
      {:ok, adventure} -> adventure
    end
  end

  def build_point(nil), do: nil

  def build_point(point_model) do
    %Creator.Adventure.Point{
      id: point_model.id,
      parent_point_id: point_model.parent_point_id,
      radius: point_model.radius,
      show: point_model.show,
      position: build_position(point_model.position),
      # answers: Enum.map(point_model.answers, &build_answer/1),
      clues: Enum.map(point_model.clues, &build_clue/1) |> Enum.sort_by(&(-1 * &1.sort))
    }
  end

  def build_position(%{coordinates: {lat, lng}} = _position) do
    %Creator.Adventure.Position{
      lat: lat,
      lng: lng
    }
  end

  def build_answer(answer_model) do
    %Creator.Adventure.Answer{
      id: answer_model.id,
      type: answer_model.type,
      details: answer_model.details
    }
  end

  def build_clue(clue_model) do
    %Creator.Adventure.Clue{
      id: clue_model.id,
      type: clue_model.type,
      sort: clue_model.sort,
      tip: clue_model.tip,
      point_id: clue_model.point_id,
      description: clue_model.description,
      asset_id: clue_model.asset_id
    }
  end
end

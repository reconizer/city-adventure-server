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
      time_answer: point_model.answers |> Enum.find(&(&1.type == "time")) |> build_time_answer,
      password_answer: point_model.answers |> Enum.find(&(&1.type == "password")) |> build_password_answer,
      clues: Enum.map(point_model.clues, &build_clue/1) |> Enum.sort_by(&(-1 * &1.sort))
    }
  end

  def build_position(%{coordinates: {lat, lng}} = _position) do
    %Creator.Adventure.Position{
      lat: lat,
      lng: lng
    }
  end

  def build_time_answer(nil), do: nil

  def build_time_answer(answer_model) do
    %Creator.Adventure.TimeAnswer{
      start_time: answer_model.details |> Map.get("start_time"),
      duration: answer_model.details |> Map.get("duration")
    }
  end

  def build_password_answer(nil), do: nil

  def build_password_answer(answer_model) do
    %Creator.Adventure.PasswordAnswer{
      type: answer_model.details |> Map.get("password_type"),
      password: answer_model.details |> Map.get("password")
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

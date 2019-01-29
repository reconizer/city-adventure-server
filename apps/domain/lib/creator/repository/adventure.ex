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
    |> preload(:asset)
    |> preload([images: :asset])
    |> preload(:creator_adventure_rating)
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
      description: adventure_model.description,
      language: adventure_model.language,
      show: adventure_model.show,
      difficulty_level: adventure_model.difficulty_level,
      max_time: adventure_model.max_time |> parse_time_to_seconds(),
      min_time: adventure_model.min_time |> parse_time_to_seconds(),
      creator_id: adventure_model.creator_id,
      status: adventure_model.status,
      rating: adventure_model.creator_adventure_rating |> adventure_rating(),
      asset: adventure_model.asset |> build_asset(),
      images: adventure_model.images |> Enum.map(&build_image/1)
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

  def build_position(%{coordinates: {lng, lat}} = _position) do
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

  defp build_asset(nil), do: nil
  defp build_asset(asset_model) do
    %Creator.Adventure.Asset{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension
    }
  end

  defp build_image(nil), do: nil
  defp build_image(image_model) do
    %Creator.Adventure.Image{
      id: image_model.id,
      sort: image_model.sort,
      asset: image_model.asset |> build_asset()
    }
  end

  defp adventure_rating(nil), do: nil
  defp adventure_rating(%{rating: rating}) do
    rating
  end

  defp parse_time_to_seconds(nil), do: nil
  defp parse_time_to_seconds(time) do
    time 
    |> Time.to_erl() 
    |> :calendar.time_to_seconds()
  end

end

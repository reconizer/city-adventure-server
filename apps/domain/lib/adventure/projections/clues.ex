defmodule Domain.Adventure.Projections.Clues do
  @moduledoc """
  Projection clues for adventure
  """

  @type t :: %__MODULE__{}

  defstruct [:id, :type, :description]

  use Infrastructure.Repository.Models
  import Ecto.Query

  alias Infrastructure.Repository

  def get_discovered_clues_for_adventure(%{adventure_id: adventure_id}, %{id: user_id}) do
    result = from(clue in Models.Clue,
      join: point in Models.Point, on: [id: clue.point_id],
      join: user_point in Models.UserPoint, on: [point_id: point.id],
      left_join: asset in assoc(clue, :asset),
      left_join: asset_conversions in assoc(asset, :asset_conversions), 
      where: user_point.completed == true,
      where: user_point.user_id == ^user_id,
      where: point.adventure_id == ^adventure_id
    )
    |> Repository.all()
    {:ok, result}
  end

  def get_clues_for_point(%{adventure_id: adventure_id, point_id: point_id}) do
    result = from(clue in Models.Clue,
      join: point in Models.Point, on: [id: clue.point_id],
      left_join: asset in assoc(clue, :asset),
      left_join: asset_conversions in assoc(asset, :asset_conversions), 
      preload: [asset: {asset, asset_conversions: asset_conversions}], 
      where: point.id == ^point_id,
      where: point.adventure_id == ^adventure_id
    )
    |> Repository.all()
    {:ok, result}
  end
end
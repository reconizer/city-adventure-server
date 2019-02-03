defmodule Domain.UserAdventure.Projections.Points do
  import Ecto.Query
  alias Infrastructure.Repository
  use Infrastructure.Repository.Models

  def get_completed_points(%{adventure_id: adventure_id, user_id: owner_id}) do
    result =
      from(point in Models.Point,
        join: user_point in Models.UserPoint,
        on: [user_id: ^owner_id, point_id: point.id],
        left_join: parent_point in Models.Point,
        on: [id: point.parent_point_id, adventure_id: ^adventure_id],
        left_join: parent_point_user in Models.UserPoint,
        on: [point_id: parent_point.id, user_id: ^owner_id],
        left_join: answer in Models.Answer,
        on: [point_id: point.id],
        select: %{
          position: point.position,
          id: point.id,
          completed: user_point.completed,
          answer_type: answer.type,
          radius: point.radius
        },
        where: point.adventure_id == ^adventure_id,
        where: user_point.completed == true or ((user_point.completed == false and parent_point_user.completed == true) or point.show == true)
      )
      |> Repository.all()

    {:ok, result}
  end

  def get_completed_points_with_clues(%{adventure_id: adventure_id, user_id: user_id}) do
    result =
      from(point in Models.Point,
        join: user_points in assoc(point, :user_points),
        left_join: clues in assoc(point, :clues),
        left_join: asset in assoc(clues, :asset),
        left_join: asset_conversions in assoc(asset, :asset_conversions),
        preload: [:user_points],
        preload: [clues: {clues, asset: {asset, asset_conversions: asset_conversions}}],
        where: user_points.completed == true,
        where: user_points.user_id == ^user_id,
        where: point.adventure_id == ^adventure_id
      )
      |> Repository.all()

    {:ok, result}
  end
end

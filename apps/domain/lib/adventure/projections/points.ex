defmodule Domain.Adventure.Projections.Points do
  import Ecto.Query
  alias Infrastructure.Repository
  use Infrastructure.Repository.Models

  def get_completed_points(%{adventure_id: adventure_id}, %{id: owner_id}) do
    result = from(point in Models.Point,
      join: user_point in Models.UserPoint, on: [user_id: ^owner_id, point_id: point.id],
      left_join: parent_point in Models.Point, on: [id: point.parent_point_id, adventure_id: ^adventure_id],
      left_join: parent_point_user in Models.UserPoint, on: [point_id: parent_point.id, user_id: ^owner_id],
      select: %{
        position: point.position,
        id: point.id,
        completed: user_point.completed
      },
      where: point.adventure_id == ^adventure_id,
      where: user_point.completed == true or (user_point.completed == false and parent_point_user.completed == true and point.show == true)
    )
    |> Repository.all()
    {:ok, result}
  end

end
defmodule Domain.Adventure.Repository.Point do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Infrastructure.Repository
  alias Ecto.Multi

  def check_point_position(%{adventure_id: adventure_id, point_id: point_id, position: %{coordinates: {lng, lat}}}) do
    from(point in Models.Point,
      where: point.id == ^point_id,
      where: point.adventure_id == ^adventure_id,
      where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), 4326)::geography, ?::geography, ?)", ^lng, ^lat, point.position, point.radius)
    )
    |> Repository.one()
    |> case do
      nil -> {:error, %{point: "not_found"}}
      result -> {:ok, result}
    end
  end

  def check_user_point(%{point_id: point_id}, %{id: user_id}) do
    from(user_point in Models.UserPoint,
      where: user_point.point_id == ^point_id,
      where: user_point.user_id == ^user_id
    )
    |> Repository.one()
    |> case do
      nil -> {:ok, :user_point_dont_exist}
      _result -> {:error, :user_alredy_exist}
    end
  end

  def create_user_point(user_point_params) do
    user_point_params
    |> Map.from_struct()
    |> Models.UserPoint.build()
    |> Repository.insert()
  end

  def update_point_as_completed(user_point) do
    user_point
    |> Repository.update(%{completed: true})
  end

  def get_answers(point) do
    result = from(answer in Models.Answer,
      where: answer.point_id == ^point.id
    )
    |> Repository.all()
    {:ok, result}
  end

end
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

  def check_last_point(point) do
    from(next_point in Models.Point,
      where: next_point.parent_point_id == ^point.id
    )
    |> Repository.one()
    |> case do
      nil -> true
      _result -> false  
    end
  end

  def join_user_to_point(params, answers, user) do
    check_user_point(params, user)
    |> case do
      {:ok, nil} -> 
        {:ok, result} = answers
        |> case do
          [] ->
            params
            |> Map.put(:user_id, user.id)
            |> Map.put(:completed, true)
            |> create_user_point()
          _result ->
            params
            |> Map.put(:user_id, user.id)
            |> create_user_point()
        end
        result
      {:ok, result} ->
        result
    end
  end

  defp check_user_point(%{point_id: point_id}, %{id: user_id}) do
    from(user_point in Models.UserPoint,
      where: user_point.point_id == ^point_id,
      where: user_point.user_id == ^user_id
    )
    |> Repository.one()
    |> case do
      nil -> {:ok, nil}
      result -> {:ok, result}
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
    |> Ecto.Changeset.change(%{completed: true})
    |> Repository.update()
  end

  def get_answers(point) do
    result = from(answer in Models.Answer,
      where: answer.point_id == ^point.id
    )
    |> Repository.all()
    {:ok, result}
  end

end
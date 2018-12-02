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
      where: fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), 4326)::geography, ?::geography, ?)", ^lat, ^lng, point.position, point.radius)
    )
    |> Repository.one()
    |> case do
      nil -> {:error, %{point: "not_found"}}
      result ->
        {:ok, result}
    end
  end

  def marke_point(%{id: point_id}, %{id: user_id}) do
    from(user_point in Models.UserPoint,
      where: user_point.point_id == ^point_id,
      where: user_point.user_id == ^user_id
    )
    |> Repository.one()
  end

end
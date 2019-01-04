defmodule Domain.Adventure.Repository.Adventure do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Infrastructure.Repository
  alias Ecto.Multi

  def start_adventure(%{adventure_id: adventure_id} = params, %Contract.User.Profile{id: id}) do
    Multi.new()
    |> Multi.run(:start_point, fn _ -> get_start_point(adventure_id) end)
    |> Multi.insert(:user_adventure, build_user_adventure(params, id), returning: true)
    |> Multi.merge(fn %{start_point: start_point} ->
      Multi.new()
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
end

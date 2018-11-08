defmodule Domain.Adventure.Repository.Adventure do
  @moduledoc """
  Repository start adventure
  """
  use Infrastructure.Repository.Models
  import Ecto.Query
  alias Ecto.Multi

  def start_adventure(%{adventure_id: adventure_id}, %Contract.User.Profile{id: id}) do
    Multi.new()
    |> Multi.run(:start_point, get_start_point(adventure_ids))
    |> Multi.insert(:user_adventure, build_user_adventure(params, id))
    |> Multi.insert(:user_point, build_user_point(params))
    |> Infrastructure.Repository.transaction()
  end

  defp build_user_adventure(%{adventure_id: id}, user_id) do
    %{
      adventure_id: id,
      user_id: user_id,
      completed: false
    }
  end

  defp build_user_point(point, user_id) do
    %{
      point_id: point.id,
      user_id: user_id,
      completed: true
    }
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
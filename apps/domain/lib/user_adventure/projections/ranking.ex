defmodule Domain.UserAdventure.Projections.Ranking do
  import Ecto.Query
  alias Infrastructure.Repository
  use Infrastructure.Repository.Models

  def get_ranking_for_adventure(%{id: adventure_id}, %{page: page, limit: limit}) do
    result =
      ranking_query(adventure_id)
      |> paginate(page, limit)
      |> Repository.all()

    {:ok, result}
  end

  def top_ten_ranking(%{id: adventure_id}) do
    result =
      ranking_query(adventure_id)
      |> limit(10)
      |> Repository.all()

    {:ok, result}
  end

  def current_user_ranking(%{id: adventure_id}, %{id: owner_id}) do
    result = ranking_query(adventure_id)
    |> where([user_ranking], user_ranking.user_id == ^owner_id)
    |> Repository.one()
    {:ok, result}
  end

  defp ranking_query(adventure_id) do
    from(user_ranking in Models.UserRanking,
      where: user_ranking.adventure_id == ^adventure_id,
      left_join: avatar in Models.Avatar, on: [user_id: user_ranking.user_id],
      left_join: asset in Models.Asset, on: [id: avatar.asset_id],
      select: %{
        position: user_ranking.position,
        user_id: user_ranking.user_id,
        nick: user_ranking.nick,
        completion_time: user_ranking.completion_time,
        adventure_id: user_ranking.adventure_id,
        asset: asset 
      },
      group_by: [user_ranking.user_id, user_ranking.position, user_ranking.nick, user_ranking.completion_time, user_ranking.adventure_id, asset.id],
      order_by: [asc: user_ranking.position]
    )
  end

  defp paginate(query, page, size) do
    from(
      query,
      limit: ^size,
      offset: ^((page - 1) * size)
    )
  end
end

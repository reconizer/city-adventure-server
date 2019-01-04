defmodule Domain.Adventure.Projections.Ranking do
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
      |> limit(11)
      |> Repository.all()

    {:ok, result}
  end

  def current_user_ranking(%{id: adventure_id}, %Contract.User.Profile{id: owner_id}) do
    result =
      ranking_query(adventure_id)
      |> where([user_ranking], user_ranking.user_id == ^owner_id)
      |> Repository.one()

    {:ok, result}
  end

  defp ranking_query(adventure_id) do
    from(user_ranking in Models.UserRanking,
      where: user_ranking.adventure_id == ^adventure_id,
      group_by: [user_ranking.user_id, user_ranking.position, user_ranking.nick, user_ranking.completion_time, user_ranking.adventure_id],
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

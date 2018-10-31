defmodule Domain.Adventure.Projections.Ranking do
  import Ecto.Query
  alias Infrastructure.Repository
  use Infrastructure.Repository.Models

  def get_ranking_for_adventure(%{page: page, limit: limit, id: adventure_id},  %Contract.User.Profile{id: owner_id}) do
    result = from(user_ranking in Models.UserRanking,
      where: user_ranking.adventure_id == ^adventure_id,
      group_by: [user_ranking.user_id, user_ranking.position, user_ranking.nick, user_ranking.completion_time, user_ranking.adventure_id],
      order_by: [desc: user_ranking.user_id == ^owner_id, asc: user_ranking.position]
    )
    |> paginate(page, limit)
    |> Repository.all()
    {:ok, result}
  end

  @spec paginate(String.t, Integer.t, Integer.t) :: String.t
  defp paginate(query, page, size) do
    from query,
    limit: ^size,
    offset: ^((page - 1) * size)
  end

end
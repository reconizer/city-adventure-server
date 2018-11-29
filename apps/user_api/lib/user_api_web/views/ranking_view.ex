defmodule UserApiWeb.RankingView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"ranking_list" => ranking_list}} = _session}) do
    ranking_list
    |> Enum.map(&render_ranking/1)
  end

  def render("current_user.json", %{session: %Session{context: %{"current_user_ranking" => ranking}} = _session}) do
    ranking
    |> render_ranking()
  end

  defp render_ranking(ranking) do
    %{
      user_id: ranking.user_id,
      position: ranking.position,
      nick: ranking.nick,
      completion_time: ranking.completion_time
    }
  end

end
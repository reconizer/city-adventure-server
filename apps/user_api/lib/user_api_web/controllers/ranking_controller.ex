defmodule UserApiWeb.RankingController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Ranking, as: RankingProjection

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- context
                                |> Contract.Adventure.Ranking.validate(),
      {:ok, paginate} <- context
                         |> Contract.Paginate.validate(),
      {:ok, ranking} <- validate_params
                        |> RankingProjection.get_ranking_for_adventure(paginate)
    do
      session
      |> Session.update_context(%{"ranking_list" => ranking})
    else
      %Session{valid?: false} ->
        session
      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.RankingView, "index.json")
  end

  def current_user_ranking(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
    {:ok, validate_params} <- context
                              |> Contract.Adventure.CurrentUserRanking.validate(),
    {:ok, current_user_ranking} <- validate_params
                                   |> RankingProjection.current_user_ranking(context["current_user"])
    do
      session
      |> Session.update_context(%{"current_user_ranking" => current_user_ranking})
    else
      %Session{valid?: false} ->
        session
      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.RankingView, "current_user.json")
    end

end
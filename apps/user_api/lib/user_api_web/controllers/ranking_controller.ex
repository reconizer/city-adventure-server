defmodule UserApiWeb.RankingController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Projections.Ranking, as: RankingProjection
  alias UserApiWeb.RankingContract

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- conn
                                |> RankingContract.index(context),
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
    {:ok, validate_params} <- conn
                              |> RankingContract.current_user_ranking(context),
    {:ok, current_user_ranking} <- validate_params
                                   |> RankingProjection.current_user_ranking()
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
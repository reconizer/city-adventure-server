defmodule UserApiWeb.RankingController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Ranking, as: RankingProjection

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- context
                                |> Contract.Adventure.Ranking.validate(),
      {:ok, ranking} <- validate_params
                        |> RankingProjection.get_ranking_for_adventure(context["current_user"])
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

end
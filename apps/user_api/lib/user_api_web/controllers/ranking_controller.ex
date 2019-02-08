defmodule UserApiWeb.RankingController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Adventure, as: AdventureDomain
  alias Domain.UserAdventure.Projections.Ranking, as: RankingProjection
  alias UserApiWeb.RankingContract

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> RankingContract.index(context),
         {:ok, paginate} <-
           context
           |> Contract.Paginate.validate(),
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get(),
         {:ok, ranking} <-
           adventure
           |> AdventureDomain.get_ranking(paginate) do
      session
      |> Session.update_context(%{"ranking_list" => ranking})
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.RankingView, "index.json")
  end

  def current_user_ranking(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> RankingContract.current_user_ranking(context),
         {:ok, current_user_ranking} <-
           validate_params
           |> RankingProjection.current_user_ranking() do
      session
      |> Session.update_context(%{"current_user_ranking" => current_user_ranking})
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.RankingView, "current_user.json")
  end
end

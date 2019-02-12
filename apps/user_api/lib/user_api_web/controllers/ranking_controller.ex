defmodule UserApiWeb.RankingController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Service.Ranking, as: RankingService
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
           |> RankingService.get_rankings_adventure(paginate) do
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
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get() do
      session
      |> Session.update_context(%{"adventure" => adventure})
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

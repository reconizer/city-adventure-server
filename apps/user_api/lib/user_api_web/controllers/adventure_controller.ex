defmodule UserApiWeb.AdventureController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Projections.Listing, as: ListingProjection
  alias Domain.UserAdventure.Projections.Adventure, as: AdventureProjection
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Projections.Ranking, as: RankingProjection
  alias UserApiWeb.AdventureContract

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    position = %{
      "lat" => context |> Map.get("lat", nil),
      "lng" => context |> Map.get("lng", nil)
    }

    with %Session{valid?: true, context: context} <-
           session
           |> Session.update_context(%{"position" => position}),
         {:ok, validate_params} <-
           conn
           |> AdventureContract.index(context),
         {:ok, start_points} <-
           validate_params
           |> ListingProjection.get_start_points() do
      session
      |> Session.update_context(%{"adventures" => start_points})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "index.json")
  end

  def show(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> AdventureContract.show(context),
         {:ok, adventure} <- validate_params |> AdventureProjection.get_adventure_by_id() do
      session
      |> Session.update_context(%{"adventure" => adventure})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "show.json")
  end

  def start(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> AdventureContract.start(context),
         {:ok, adventure} <- validate_params |> AdventureRepository.start_adventure() do
      session
      |> Session.update_context(%{"adventure" => adventure})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "start.json")
  end

  def summary(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> AdventureContract.summary(context),
         {:ok, ranking} <-
           validate_params
           |> RankingProjection.top_ten_ranking() do
      session
      |> Session.update_context(%{"ranking" => ranking})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "summary.json")
  end
end

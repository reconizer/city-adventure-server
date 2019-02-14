defmodule UserApiWeb.AdventureController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Repository.Lisiting, as: ListingRepository
  alias Domain.UserAdventure.Service.Ranking, as: RankingService
  alias Domain.UserAdventure.Service.Rating, as: RatingService
  alias Domain.UserAdventure.Adventure, as: AdventureDomain
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
           |> ListingRepository.get_all() do
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
         {:ok, adventure} <- validate_params |> AdventureRepository.get(),
         {:ok, ranking} <-
           adventure
           |> RankingService.top_five(),
         {:ok, rating} <-
           adventure
           |> RatingService.get_rating() do
      session
      |> Session.update_context(%{"adventure" => adventure, "rankings" => ranking, "rating" => rating})
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
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get(),
         {:ok, _adventure} <-
           adventure
           |> AdventureDomain.check_adventure_started(),
         {:ok, start_point} <-
           adventure
           |> AdventureDomain.find_start_point() do
      adventure
      |> AdventureDomain.start_adventure(validate_params, start_point)
      |> case do
        {:ok, started_adventure} ->
          started_adventure
          |> AdventureRepository.save()

          session
          |> Session.update_context(%{"start_point" => start_point})
      end
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "start.json")
  end

  def rating(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> AdventureContract.rating(context),
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get(),
         {:ok, _adventure} <-
           adventure
           |> AdventureDomain.can_rate?() do
      adventure
      |> AdventureDomain.create_adventure_rating(validate_params)
      |> case do
        {:ok, adventure_rating} ->
          adventure_rating
          |> AdventureRepository.save()

          session
          |> Session.update_context(%{"adventure" => adventure_rating})
      end
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.AdventureView, "rating.json")
  end

  def summary(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> AdventureContract.summary(context),
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get(),
         {:ok, ranking} <-
           adventure
           |> RankingService.top_ten() do
      session
      |> Session.update_context(%{"adventure" => adventure, "rankings" => ranking})
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

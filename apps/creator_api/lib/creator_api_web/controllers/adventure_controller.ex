defmodule CreatorApiWeb.AdventureController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.AdventureContract
  alias Domain.Creator

  def list(conn, params) do
    with {:ok, params} <- AdventureContract.list(conn, params),
         {:ok, adventures} <- Creator.Service.Adventure.get_creator_adventures(params.creator_id) do
      conn
      |> render("list.json", %{list: adventures})
    else
      {:error, error} ->
        conn
        |> handle_errors(error)
    end
  end

  def item(conn, params) do
    with {:ok, params} <- AdventureContract.item(conn, params),
         {:ok, adventure} <- Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id) do
      conn
      |> render("item.json", %{item: adventure})
    else
      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def statistics(conn, params) do
    AdventureContract.statistics(conn, params)
    |> case do
      {:ok, _params} ->
        conn
        |> resp(200, "OK")

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    AdventureContract.create(conn, params)
    |> case do
      {:ok, params} ->
        Domain.Creator.Adventure.new(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> case do
          {:ok, _} ->
            Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.id)
            |> case do
              {:ok, adventure} ->
                conn
                |> render("item.json", %{item: adventure})

              {:error, errors} ->
                conn
                |> handle_errors(errors)
            end

          error ->
            error
            |> handle_repository_action(conn)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def update(conn, params) do
    AdventureContract.update(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.change(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def send_to_pending(conn, params) do
    AdventureContract.send_to_pending(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.send_to_pending()
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def send_to_review(conn, params) do
    AdventureContract.send_to_review(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.send_to_review()
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end

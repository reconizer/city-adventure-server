defmodule AdministrationApiWeb.AdventureController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.AdventureContract
  alias Domain.Creator.Repository.Adventure, as: AdventureRepository

  def list(conn, params) do
    with {:ok, params} <- AdventureContract.list(conn, params),
         {:ok, adventures} <- AdventureRepository.all(params.filter) do
      conn
      |> render("list.json", %{list: adventures})
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  def item(conn, params) do
    with {:ok, params} <- AdventureContract.item(conn, params),
         {:ok, adventure} <- AdventureRepository.get(params.adventure_id) do
      conn
      |> render("item.json", %{item: adventure})
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  def statistics(conn, params) do
    AdventureContract.statistics(conn, params)
    |> case do
      {:ok, _params} ->
        conn
        |> put_status(200)
        |> json(%{})

      error ->
        conn
        |> handle_error(error)
    end
  end

  def create(conn, params) do
    with {:ok, params} <- AdventureContract.create(conn, params),
         {:ok, _} <- Domain.Creator.Adventure.new(params) |> Domain.Creator.Repository.Adventure.save(),
         {:ok, adventure} <- AdventureRepository.get(params.id) do
      conn
      |> render("item.json", %{item: adventure})
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  def update(conn, params) do
    with {:ok, params} <- AdventureContract.update(conn, params) do
      AdventureRepository.get(params.adventure_id)
      |> Domain.Creator.Adventure.change(params)
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  def send_to_pending(conn, params) do
    with {:ok, params} <- AdventureContract.send_to_pending(conn, params) do
      AdventureRepository.get(params.adventure_id)
      |> Domain.Creator.Adventure.send_to_pending()
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  def send_to_review(conn, params) do
    with {:ok, params} <- AdventureContract.send_to_review(conn, params) do
      AdventureRepository.get(params.adventure_id)
      |> Domain.Creator.Adventure.send_to_review()
      |> Domain.Creator.Repository.Adventure.save()
      |> handle_repository_action(conn)
    else
      error ->
        conn
        |> handle_error(error)
    end
  end
end

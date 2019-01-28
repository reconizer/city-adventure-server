defmodule CreatorApiWeb.PointController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.PointContract
  alias Domain.Creator

  def item(conn, params) do
    PointContract.item(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> case do
          {:ok, adventure} ->
            adventure
            |> Creator.Adventure.get_point(params.id)
            |> case do
              {:ok, point} ->
                conn
                |> render("item.json", %{item: point})

              {:error, errors} ->
                conn
                |> handle_errors(errors)
            end

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def list(conn, params) do
    PointContract.list(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> case do
          {:ok, adventure} ->
            conn
            |> render("list.json", %{list: adventure.points})

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    PointContract.create(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Creator.Adventure.add_point(%{
          id: params.id,
          parent_point_id: params.parent_point_id,
          radius: params.radius,
          show: params.show,
          position: %{
            lat: params.position.lat,
            lng: params.position.lng
          }
        })
        |> Domain.Creator.Repository.Adventure.save()
        |> case do
          {:ok, adventure} ->
            adventure
            |> Creator.Adventure.get_point(params.id)
            |> case do
              {:ok, point} ->
                conn
                |> render("item.json", %{item: point})

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
    PointContract.update(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.change_point(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def delete(conn, params) do
    PointContract.delete(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.remove_point(params.id)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def reorder(conn, params) do
    PointContract.reorder(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.reorder_points(params.point_order)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end

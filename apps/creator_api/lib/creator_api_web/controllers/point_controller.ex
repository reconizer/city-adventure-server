defmodule CreatorApiWeb.PointController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.PointContract
  alias Domain.Creator

  def create(conn, params) do
    PointContract.create(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Creator.Adventure.add_point(%{
          parent_point_id: params.parent_point_id,
          radius: params.radius,
          show: params.show,
          position: %{
            lat: params.position.lat,
            lng: params.position.lng
          }
        })
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

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

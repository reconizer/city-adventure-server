defmodule CreatorApiWeb.PointController do
  use CreatorApiWeb, :controller

  alias Domain.Creator

  import Contract

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      position: CreatorApi.Type.Position,
      radius: :integer,
      parent_point_id: Ecto.UUID,
      show: :boolean
    })
    |> default(%{
      show: false,
      radius: 10
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required,
      position: :required,
      parent_point_id: :required
    })
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
    params
    |> with_creator(conn)
    |> cast(%{
      point_id: Ecto.UUID,
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      position: CreatorApi.Type.Position,
      radius: :integer,
      parent_point_id: Ecto.UUID,
      show: :boolean
    })
    |> validate(%{
      creator_id: :required,
      point_id: :required,
      adventure_id: :required
    })
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
    params
    |> with_creator(conn)
    |> cast(%{
      id: Ecto.UUID,
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      creator_id: :required,
      id: :required
    })
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
    params
    |> with_creator(conn)
    |> cast(%{
      point_order: {:array, CreatorApi.Type.PointOrder},
      adventure_id: Ecto.UUID,
      creator_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      creator_id: :required,
      point_order: :required
    })
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

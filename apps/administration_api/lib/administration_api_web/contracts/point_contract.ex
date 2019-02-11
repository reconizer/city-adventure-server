defmodule AdministrationApiWeb.PointContract do
  use AdministrationApiWeb, :contract

  def list(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      administrator_id: :required,
      adventure_id: :required
    })
  end

  def item(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      id: Ecto.UUID
    })
    |> validate(%{
      id: :required,
      administrator_id: :required,
      adventure_id: :required
    })
  end

  def create(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      position: AdministrationApi.Type.Position,
      radius: :integer,
      parent_point_id: Ecto.UUID,
      show: :boolean
    })
    |> default(%{
      show: false,
      radius: 10,
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      administrator_id: :required,
      adventure_id: :required,
      position: :required,
      parent_point_id: :required
    })
  end

  def update(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      id: Ecto.UUID,
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      position: AdministrationApi.Type.Position,
      radius: :integer,
      parent_point_id: Ecto.UUID,
      show: :boolean,
      time_answer: AdministrationApi.Type.TimeAnswer,
      password_answer: AdministrationApi.Type.PasswordAnswer
    })
    |> validate(%{
      administrator_id: :required,
      id: :required,
      adventure_id: :required
    })
  end

  def delete(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      id: Ecto.UUID,
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      administrator_id: :required,
      id: :required
    })
  end

  def reorder(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      point_order: {:array, AdministrationApi.Type.PointOrder},
      adventure_id: Ecto.UUID,
      administrator_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      administrator_id: :required,
      point_order: :required
    })
  end
end

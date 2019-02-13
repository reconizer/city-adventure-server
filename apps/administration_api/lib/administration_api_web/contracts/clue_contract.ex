defmodule AdministrationApiWeb.ClueContract do
  use AdministrationApiWeb, :contract

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
      adventure_id: Ecto.UUID,
      administrator_id: Ecto.UUID,
      point_id: Ecto.UUID,
      type: :string,
      description: :string,
      tip: :boolean,
      url: :string
    })
    |> default(%{
      tip: false,
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      adventure_id: :required,
      administrator_id: :required,
      point_id: :required,
      type: :required,
      description: :required
    })
  end

  def update(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      id: Ecto.UUID,
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      point_id: Ecto.UUID,
      type: :string,
      description: :string,
      tip: :boolean,
      url: :string
    })
    |> validate(%{
      id: :required,
      administrator_id: :required,
      adventure_id: :required
    })
  end

  def delete(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      administrator_id: :required,
      id: :required,
      adventure_id: :required
    })
  end

  def reorder(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      clue_order: {:array, AdministrationApi.Type.ClueOrder}
    })
    |> validate(%{
      administrator_id: :required,
      clue_order: :required,
      adventure_id: :required
    })
  end
end

defmodule AdministrationApiWeb.Creator.AdventureContract do
  use AdministrationApiWeb, :contract

  def list(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      administrator_id: Ecto.UUID
    })
    |> validate(%{
      administrator_id: :required
    })
  end

  def item(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      adventure_id: Ecto.UUID,
      administrator_id: Ecto.UUID
    })
    |> validate(%{
      adventure_id: :required,
      administrator_id: :required
    })
  end
end

defmodule AdministrationApiWeb.QAController do
  use AdministrationApiWeb, :contract

  def list(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
  end

  def create(conn, params) do
    params
    |> with_administrator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      content: :string
    })
    |> default(%{
      id: Ecto.UUID.generate()
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required,
      content: :string
    })
  end
end

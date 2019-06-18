defmodule CreatorApiWeb.QAContract do
  use CreatorApiWeb, :contract

  def list(conn, params) do
    params
    |> with_creator(conn)
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
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      content: :string
    })
    |> default(%{
      id: Ecto.UUID.generate(),
      created_at: NaiveDateTime.utc_now()
    })
    |> validate(%{
      id: :required,
      creator_id: :required,
      adventure_id: :required,
      content: :string
    })
  end
end

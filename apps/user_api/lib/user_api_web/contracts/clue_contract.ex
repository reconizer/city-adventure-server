defmodule UserApiWeb.ClueContract do
  use UserApiWeb, :contract

  def index(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required,
      adventure_id: :required
    })
  end

  def list_for_points(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      point_id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required,
      adventure_id: :required,
      point_id: :required
    })
  end

end
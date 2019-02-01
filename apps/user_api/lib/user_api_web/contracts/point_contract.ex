defmodule UserApiWeb.PointContract do
  use UserApiWeb, :contract

  def list_of_completed_points(conn, params) do
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

  def resolve_point(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID,
      position: UserApi.Type.Position,
      adventure_id: Ecto.UUID,
      answer_text: :string,
      answer_type: :string
    })
    |> validate(%{
      user_id: :required,
      position: :required,
      adventure_id: :required
    })
  end

end
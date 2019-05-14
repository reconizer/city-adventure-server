defmodule UserApiWeb.CreatorContract do
  use UserApiWeb, :contract

  def show(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      user_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      user_id: :required
    })
  end
end

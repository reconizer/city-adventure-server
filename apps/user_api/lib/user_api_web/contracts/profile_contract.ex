defmodule UserApiWeb.ProfileContract do
  use UserApiWeb, :contract

  def show(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      user_id: Ecto.UUID
    })
    |> validate(%{
      user_id: :required
    })
  end
end

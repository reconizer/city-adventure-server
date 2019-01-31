defmodule UserApiWeb.AdventureContract do
  use UserApiWeb, :contract

  def index(conn, params) do
    params
    |> with_user(conn)
    |> cast(%{
      position: UserApi.Type.Position
    })
    |> validate(%{
      position: :required
    })
  end

end
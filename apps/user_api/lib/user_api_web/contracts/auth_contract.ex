defmodule UserApiWeb.AuthContract do
  use UserApiWeb, :contract

  def register(_conn, params) do
    params
    |> cast(%{
      email: :string,
      password: :string,
      password_confirmation: :string,
      nick: :string
    })
    |> validate(%{
      email: :required,
      password: :required,
      password_confirmation: :required,
      nick: :required
    })
  end
end

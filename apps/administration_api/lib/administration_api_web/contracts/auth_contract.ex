defmodule AdministrationApiWeb.AuthContract do
  use AdministrationApiWeb, :contract

  def login(_conn, params) do
    params
    |> cast(%{
      email: :string,
      password: :string
    })
    |> validate(%{
      email: :required,
      password: :required
    })
  end
end

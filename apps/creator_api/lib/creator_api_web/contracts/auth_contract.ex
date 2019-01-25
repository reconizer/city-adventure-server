defmodule CreatorApiWeb.AuthContract do
  use CreatorApiWeb, :contract

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

  def register(_conn, params) do
    params
    |> cast(%{
      email: :string,
      password: :string,
      name: :string
    })
    |> validate(%{
      email: :required,
      password: :required,
      name: :required
    })
  end

  def logout(_conn, _params) do
    {:ok, []}
  end
end

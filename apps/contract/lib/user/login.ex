defmodule Contract.User.Login do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :email, :string 
    field :password, :string
  end

  @params ~w(email password)a
  @required_params ~w(email password)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/@/)
  end

end
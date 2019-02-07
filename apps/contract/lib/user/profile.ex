defmodule Contract.User.Profile do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  @params ~w(email nick id)a
  @required_params ~w(email nick id)a

  embedded_schema do
    field :email, :string 
    field :nick, :string
  end

  defp changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end
  
end
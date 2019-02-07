defmodule Contract.Adventure.Ranking do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, Ecto.UUID
  end

  @params ~w(id)a
  @required_params ~w(id)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
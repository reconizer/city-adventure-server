defmodule Contract.Adventure.Start do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  embedded_schema do
    field :adventure_id, Ecto.UUID
  end

  @params ~w(adventure_id)a
  @required_params ~w(adventure_id)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
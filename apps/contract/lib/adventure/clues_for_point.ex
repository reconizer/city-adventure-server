defmodule Contract.Adventure.CluesForPoint do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :adventure_id, Ecto.UUID
    field :point_id, Ecto.UUID
  end

  @params ~w(adventure_id point_id)a
  @required_params ~w(adventure_id point_id)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
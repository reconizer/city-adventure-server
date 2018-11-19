defmodule Contract.Adventure.Ranking do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, Ecto.UUID
    field :page, :integer, default: 1
    field :limit, :integer, default: 10
  end

  @params ~w(id page limit)a
  @required_params ~w(id)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
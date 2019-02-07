defmodule Contract.Adventure.Summary do
  use Ecto.Schema
  use Contract

  embedded_schema do
  end

  @params ~w(id)a
  @required_params ~w(id)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
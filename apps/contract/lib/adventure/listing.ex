defmodule Contract.Adventure.Listing do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset
  alias Contract.Position

  @primary_key false

  embedded_schema do
    field :position, Geo.PostGIS.Geometry
  end

  @params ~w(position)a
  @required_params ~w(position)a

  def changeset(contract, params) do 
    params = Position.position_cast(params)
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
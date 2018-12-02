defmodule Contract.Adventure.PointPosition do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset
  alias Contract.Position

  @primary_key false

  embedded_schema do
    field :adventure_id, Ecto.UUID
    field :point_id, Ecto.UUID
    field :position, Geo.PostGIS.Geometry
  end

  @params ~w(position point_id adventure_id)a
  @required_params ~w(position point_id adventure_id)a

  def changeset(contract, params) do 
    params = Position.position_cast(params)
    contract
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
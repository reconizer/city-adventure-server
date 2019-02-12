defmodule Domain.UserAdventure.Listing do
  use Ecto.Schema
  use Domain.Event, "UserAdventureLisitng"

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:start_point_id, Ecto.UUID)
    field(:started, :boolean)
    field(:completed, :boolean)
    field(:position, Geo.PostGIS.Geometry)
    field(:paid, :boolean)
    field(:purchased, :boolean)

    aggregate_fields()
  end
end

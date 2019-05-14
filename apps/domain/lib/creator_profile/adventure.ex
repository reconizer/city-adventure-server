defmodule Domain.CreatorProfile.Adventure do
  use Ecto.Schema

  alias Domain.CreatorProfile.Asset

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:difficulty_level, :integer)
    field(:min_time, :integer)
    field(:max_time, :integer)
    field(:rating, :decimal)
    embeds_one(:asset, Asset)
  end
end

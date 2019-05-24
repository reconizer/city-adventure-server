defmodule Domain.CreatorProfile.Creator do
  use Ecto.Schema
  alias Domain.CreatorProfile.Asset

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:description, :string)
    embeds_one(:asset, Asset)
  end
end

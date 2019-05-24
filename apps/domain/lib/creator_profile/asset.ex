defmodule Domain.CreatorProfile.Asset do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:type, :string)
    field(:name, :string)
    field(:extension, :string)
  end
end

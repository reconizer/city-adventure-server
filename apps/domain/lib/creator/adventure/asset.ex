defmodule Domain.Creator.Adventure.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:type, :string)
    field(:name, :string)
    field(:extension, :string)
    embeds_many(:asset_conversions, Adventure.AssetConversion)
  end

  @fields ~w(id type name extension)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  @spec new(Map.t()) :: entity()
  def new(%{id: id, type: type, name: name, extension: extension}) do
    %Adventure.Asset{
      id: id
    }
    |> changeset(%{
      type: type,
      name: name,
      extension: extension
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end
end

defmodule Domain.Creator.Adventure.Image do
  use Ecto.Schema
  import Ecto.Changeset

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:sort, :integer)
    field(:asset_id, :binary_id)
    field(:adventure_id, :binary_id)
    embeds_one(:asset, Adventure.Asset)
  end

  @fields ~w(sort adventure_id asset_id)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def new(%{adventure_id: adventure_id, asset_id: asset_id, sort: sort}) do
    %Adventure.Image{
      id: Ecto.UUID.generate()
    }
    |> changeset(%{
      adventure_id: adventure_id,
      asset_id: asset_id,
      sort: sort
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end

  def update({:ok, image}, image_params), do: update(image, image_params)
  def update({:error, _} = error, _), do: error

  def update(image, image_params) do
    image
    |> changeset(image_params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, {changeset |> apply_changes, changeset.changes}}

      changeset ->
        {:error, changeset}
    end
  end
end

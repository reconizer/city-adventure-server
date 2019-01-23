defmodule CreatorApi.Type.Point do
  use CreatorApi.Type

  alias CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:parent_id, :binary_id)
    field(:radius, :float)
    field(:hidden, :boolean)
    embeds_one(:position, Type.Position)
    embeds_many(:clues, Type.Clue)
    embeds_many(:answers, Type.Answer)
  end

  @fields ~w(id parent_id radius hidden)a
  @required_fields ~w(id radius hidden)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:position)
    |> cast_embed(:clues)
    |> cast_embed(:answers)
  end

  def cast(%{"lat" => lat, "lng" => lng}) do
    changeset =
      %CreatorApi.Type.Position{}
      |> changeset(%{
        lat: lat,
        lng: lng
      })

    cond do
      changeset.valid? ->
        {:ok, apply_changes(changeset)}

      true ->
        :error
    end
  end
end

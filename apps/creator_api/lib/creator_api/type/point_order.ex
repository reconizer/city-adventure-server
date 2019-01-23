defmodule CreatorApi.Type.PointOrder do
  @behaviour Ecto.Type
  use CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:parent_point_id, :binary_id)
  end

  @fields ~w(id parent_point_id)a
  @required_fields ~w(id)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"parent_point_id" => parent_point_id, "id" => id}) do
    changeset =
      %CreatorApi.Type.PointOrder{}
      |> changeset(%{
        id: id,
        parent_point_id: parent_point_id
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           id: id,
           parent_point_id: parent_point_id
         }}

      true ->
        :error
    end
  end

  def cast(_) do
    :error
  end
end

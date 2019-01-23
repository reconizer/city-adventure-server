defmodule CreatorApi.Type.ClueOrder do
  @behaviour Ecto.Type
  use CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:point_id, :binary_id)
    field(:sort, :integer)
  end

  @fields ~w(id point_id sort)a
  @required_fields ~w(id point_id sort)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"point_id" => point_id, "id" => id, "sort" => sort}) do
    changeset =
      %CreatorApi.Type.ClueOrder{}
      |> changeset(%{
        id: id,
        point_id: point_id,
        sort: sort
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           id: id,
           point_id: point_id,
           sort: sort
         }}

      true ->
        :error
    end
  end

  def cast(_) do
    :error
  end
end

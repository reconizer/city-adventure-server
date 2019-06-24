defmodule CreatorApi.Type.ImageOrder do
  @behaviour Ecto.Type
  use CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:sort, :integer)
  end

  @fields ~w(id sort)a
  @required_fields ~w(id sort)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"id" => id, "sort" => sort}) do
    changeset =
      %CreatorApi.Type.ImageOrder{}
      |> changeset(%{
        id: id,
        sort: sort
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           id: changeset.changes.id,
           sort: changeset.changes.sort
         }}

      true ->
        :error
    end
  end

  def cast(_) do
    :error
  end

  def type() do
  end

  def load(_) do
    {:ok, nil}
  end

  def dump(_) do
    {:ok, nil}
  end
end

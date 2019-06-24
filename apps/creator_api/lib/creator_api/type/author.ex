defmodule CreatorApi.Type.Author do
  @behaviour Ecto.Type
  use CreatorApi.Type

  embedded_schema do
    field(:id, :binary_id)
    field(:type, :string)
  end

  @fields ~w(id type)a
  @required_fields ~w(id)a

  def new(%{"creator_id" => id}) do
    %{id: id, type: "creator"}
  end

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"id" => id, "type" => type}) do
    changeset =
      %CreatorApi.Type.Author{}
      |> changeset(%{
        id: id,
        type: type
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           id: changeset.changes.id,
           type: changeset.changes.type
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

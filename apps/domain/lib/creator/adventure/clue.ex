defmodule Domain.Creator.Adventure.Clue do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, validate_inclusion: 3, apply_changes: 1]

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:point_id, :binary_id)
    field(:type, :string)
    field(:description, :string)
    field(:tip, :boolean)
    field(:sort, :integer)
    field(:asset_id, :binary_id)
  end

  @fields ~w(id type description tip sort asset_id point_id)a
  @required_fields @fields -- [:asset_id]

  @available_types ~w(text audio video image url)

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @available_types)
  end

  def new(%{id: id, type: type, description: description, tip: tip, sort: sort, point_id: point_id}) do
    %Adventure.Clue{
      id: id
    }
    |> changeset(%{
      type: type,
      description: description,
      tip: tip,
      sort: sort,
      point_id: point_id
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end

  def change({:ok, clue}, clue_params), do: change(clue, clue_params)
  def change({:error, _} = error, _), do: error

  def change(clue, clue_params) do
    clue
    |> Adventure.Clue.changeset(clue_params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, {changeset |> apply_changes, changeset.changes}}

      changeset ->
        {:error, changeset}
    end
  end
end

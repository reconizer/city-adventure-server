defmodule Domain.Creator.Adventure.Clue do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, validate_inclusion: 3, apply_changes: 1]

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()
  @type entity_changeset :: {:ok, {t(), Map.t()}} | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:point_id, :binary_id)
    field(:type, :string)
    field(:description, :string)
    field(:tip, :boolean)
    field(:sort, :integer)
    field(:asset_id, :binary_id)
    field(:url, :string)

    embeds_one(:asset, Adventure.Asset)
  end

  @fields ~w(id type description tip sort asset_id point_id url)a
  @required_fields @fields -- [:asset_id, :url, :description]

  @available_types ~w(text audio video image url)

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @available_types)
  end

  @spec new(Map.t()) :: entity()
  def new(%{id: id, type: type, description: description, tip: tip, sort: sort, point_id: point_id, url: url}) do
    %Adventure.Clue{
      id: id
    }
    |> changeset(%{
      type: type,
      description: description,
      tip: tip,
      sort: sort,
      point_id: point_id,
      url: url
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end

  @spec change(t() | entity(), Map.t()) :: entity_changeset()
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

defmodule Domain.AdventureReview.Adventure do
  use Ecto.Schema
  use Domain.Event, "AdventureReview.Adventure"
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, cast_embed: 2, apply_changes: 1]

  alias Domain.AdventureReview
  alias Domain.AdventureReview.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:status, :string)
    embeds_one(:creator, Adventure.Creator)
    aggregate_fields()
  end

  @fields ~w(id creator_id status)a
  @required_fields ~w(id creator_id status)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:creator)
  end

  def change({:ok, adventure}, params), do: change(adventure, params)
  def change({:error, _} = error, _), do: error

  def change(adventure, params) do
    adventure
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> apply_changes
        |> emit("Changed", changeset.changes)

      changeset ->
        {:error, changeset}
    end
  end
end

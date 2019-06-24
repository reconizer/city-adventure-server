defmodule Domain.AdventureReview.Adventure.Creator do
  use Ecto.Schema
  use Domain.Event, "AdventureReview.Adventure"
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, cast_embed: 2, apply_changes: 1]

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  alias Domain.AdventureReview.Adventure

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:email, :string)
  end

  @fields ~w(id name email)a
  @required_fields ~w(id name email)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def new(params) do
    %Adventure.Creator{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end
end

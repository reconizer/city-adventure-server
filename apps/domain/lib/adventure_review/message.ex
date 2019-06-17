defmodule Domain.AdventureReview.Message do
  use Ecto.Schema
  use Domain.Event, "AdventureReview.Message"
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, cast_embed: 2, apply_changes: 1]

  alias Domain.AdventureReview.Message

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    embeds_one(:author, Message.Author)
    field(:content, :string)
    field(:adventure_id, :binary_id)

    field(:created_at, :naive_datetime)
    aggregate_fields()
  end

  @fields ~w(id content created_at adventure_id)a
  @required_fields ~w(id content created_at adventure_id)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:author)
  end

  # %{id: id, content: content, created_at: created_at, author: author}) do
  def new(params) do
    %Message{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
    |> case do
      {:error, _} = error ->
        error

      {:ok, message} ->
        message
        |> emit("Created", %{
          adventure_id: message.adventure_id,
          content: message.content,
          created_at: message.created_at,
          author_id: message.author.id,
          author_type: message.author.type
        })
    end
  end
end

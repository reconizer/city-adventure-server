defmodule Domain.Creator.User do
  use Ecto.Schema
  use Domain.Event, "Creator.User"
  import Ecto.Changeset

  alias Domain.Creator.User

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:email, :string)

    embeds_many(:adventures, User.Adventure)

    aggregate_fields()
  end

  @fields ~w(id name email)a
  @required_fields @fields

  @spec changeset(Transfer.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:adventures)
  end

  def new(user_params, password) do
    %Domain.Creator.User{
      id: Ecto.UUID.generate()
    }
    |> changeset(user_params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
    |> case do
      {:error, _} = error ->
        error

      {:ok, user} ->
        user
        |> emit("Created", %{
          id: user.id,
          password_digest: Comeonin.Bcrypt.hashpwsalt(password),
          email: user.email |> String.downcase(),
          name: user.name
        })
    end
  end

  @spec get_adventure(t, Ecto.UUID.t()) :: {:error, any()} | {:ok, User.Adventure.t()}
  def get_adventure(user, adventure_id) do
    user.adventures
    |> Enum.find(&(&1.id == adventure_id))
    |> case do
      nil -> {:error, {:adventure_id, "not found in user"}}
      adventure -> {:ok, adventure}
    end
  end
end

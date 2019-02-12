defmodule Domain.Profile.Registration do
  use Ecto.Schema
  use Domain.Event, "Profile.Registration"
  import Ecto.Changeset

  alias Domain.Profile.Registration

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:nick, :string)
    field(:email, :string)

    field(:password, :string)
    field(:password_confirmation, :string)

    aggregate_fields()
  end

  @fields ~w(id nick email password password_confirmation)a
  @required_fields @fields

  @spec changeset(Transfer.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_confirmation(:password)
  end

  def new({:ok, params}), do: new(params)
  def new({:error, _} = error), do: error

  def new(params) do
    %Registration{
      id: Ecto.UUID.generate()
    }
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

      {:ok, user} ->
        user
        |> emit("Created", %{
          id: user.id,
          password_digest: Comeonin.Bcrypt.hashpwsalt(user.password),
          email: user.email |> String.downcase(),
          nick: user.nick
        })
    end
  end
end

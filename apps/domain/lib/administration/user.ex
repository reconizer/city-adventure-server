defmodule Domain.Administration.User do
  use Ecto.Schema
  use Domain.Event, "Administration.User"
  import Ecto.Changeset

  alias Domain.Administration.User

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @type new_params :: %{required(:email) => String.t(), required(:name) => String.t(), required(:password) => String.t(), optional(:id) => Ecto.UUID.t()}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:email, :string)

    aggregate_fields()
  end

  @fields ~w(id name email)a
  @required_fields @fields

  @spec changeset(t() | entity(), map()) :: error | Ecto.Changeset.t()
  def changeset({:ok, struct}, params), do: changeset(struct, params)
  def changeset({:error, _} = error, _), do: error

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  @spec new(new_params() | {:ok, new_params()} | error) :: entity()
  def new({:ok, user_params}), do: new(user_params)
  def new({:error, _} = error), do: error

  def new(user_params) do
    with {:ok, password} <- user_params |> Map.fetch(:password),
         user_params <- user_params |> Map.take(Map.keys(user_params) -- [:password]),
         id <- user_params |> Map.get(:id, Ecto.UUID.generate()),
         user <- %User{id: id} do
      user
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
    else
      :error -> {:error, "Password is required"}
    end
  end
end

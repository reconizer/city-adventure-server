defmodule Contract.Adventure.Ranking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, Ecto.UUID
    field :page, :integer, default: 1
    field :limit, :integer, default: 10
  end

  @params ~w(id page limit)a
  @required_params ~w(id)a

  def validate(params) do
    params
    |> changeset()
    |> case do
      %{valid?: true} = result -> 
        {:ok, result
              |> apply_changes()
        }
      result -> {:error, result.errors} 
    end
  end

  def changeset(params, model \\ %__MODULE__{}) do 
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
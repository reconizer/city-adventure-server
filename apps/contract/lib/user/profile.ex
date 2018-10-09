defmodule Contract.User.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @params ~w(email nick id)a
  @required_params ~w(email nick id)a

  embedded_schema do
    field :email, :string 
    field :nick, :string
  end

  def validate(params) do
    params
    |> changeset()
    |> case do
      %{valid?: true} = login -> 
        result = login
        |> apply_changes()
        {:ok, result}
      result -> {:error, result.errors} 
    end
  end

  defp changeset(params) do 
    %__MODULE__{}
    |> cast(params, @params)
    |> validate_required(@required_params)
  end
  
end
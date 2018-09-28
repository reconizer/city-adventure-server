defmodule Contract.User.Login do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :email, :string 
    field :password, :string
  end

  @params ~w(email password)a
  @required_params ~w(email password)a

  def validate(params) do
    params
    |> changeset()
    |> case do
      %{valid?: true} = login -> 
        result = login
        |> apply_changes()
        {:ok, result}
      result -> {:error, result} 
    end
  end

  defp changeset(params) do 
    %__MODULE__{}
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/@/)
  end

end
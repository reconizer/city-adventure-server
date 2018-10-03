defmodule Contract.User.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @params ~w(email nick id)a
  @required_params ~w(email nick id)a

  embedded_schema do
    field :email, :string 
    field :nick, :string
  end

  def changeset(model, params) do 
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
  end
  
end
defmodule Contract.Paginate do
  use Ecto.Schema
  use Contract
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :page, :integer, default: 1
    field :limit, :integer, default: 10
  end

  @params ~w(page limit)a

  def changeset(contract, params) do 
    contract
    |> cast(params, @params)
  end

end
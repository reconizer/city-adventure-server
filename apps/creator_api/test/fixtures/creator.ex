defmodule CreatorApiWeb.Fixtures.Creator do
  alias Domain.Creator

  def new(params) do
    Creator.User.new(
      %{
        id: Map.get(params, :id),
        email: Map.get(params, :email),
        name: Map.get(params, :name)
      },
      Map.get(params, :password)
    )
    |> Creator.Repository.User.save()
  end
end

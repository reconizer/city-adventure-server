defmodule CreatorApiWeb.Fixtures.Creator do
  alias Domain.Creator

  def new(params) do
    Creator.User.new(
      %{
        email: params |> Map.get(:email),
        name: params |> Map.get(:name)
      },
      params |> Map.get(:password)
    )
    |> Creator.Repository.User.save()
  end
end

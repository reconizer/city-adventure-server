defmodule Domain.AdventureReview.MessageTest do
  use ExUnit.Case, async: true

  alias Domain.Administration.User, as: Administrator
  alias Domain.Administration.User.Repository, as: AdministratorRepository
  alias Domain.Creator.User, as: Creator
  alias Domain.Creator.Repository.User, as: CreatorRepository

  alias Domain.Creator.Adventure, as: Adventure
  alias Domain.Creator.Repository.Adventure, as: AdventureRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)

    {:ok, administrator} =
      Administrator.new(%{email: "test@test.pl", password: "testtest", name: "test"})
      |> AdministratorRepository.save()

    {:ok, creator} =
      Creator.new(%{email: "test@test.pl", name: "test"}, "testtest")
      |> CreatorRepository.save()

    {:ok, adventure} =
      Adventure.new(%{
        id: Ecto.UUID.generate(),
        position: %{lat: 1, lng: 1},
        creator_id: creator.id,
        name: "test"
      })
      |> AdventureRepository.save()

    [
      administrator_id: administrator.id,
      creator_id: creator.id
    ]
  end

  @tag :wip
  test "", context do
  end
end

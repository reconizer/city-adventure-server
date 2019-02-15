defmodule Domain.AdventureReview.MessageTest do
  use ExUnit.Case, async: true

  alias Domain.Administration.User, as: Administrator
  alias Domain.Administration.User.Repository, as: AdministratorRepository
  alias Domain.Creator.User, as: Creator
  alias Domain.Creator.Repository.User, as: CreatorRepository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Infrastructure.Repository)

    {:ok, administrator} =
      Administrator.new(%{email: "test@test.pl", password: "testtest", name: "test"})
      |> AdministratorRepository.save()

    {:ok, creator} =
      Creator.new(%{email: "test@test.pl", name: "test"}, "testtest")
      |> CreatorRepository.save()

    [
      administrator_id: administrator.id,
      creator_id: creator.id
    ]
  end

  @tag :wip
  test "", context do
    context
    |> IO.inspect()
  end
end

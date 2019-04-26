defmodule UserApiWeb.Fixtures.Setup do
  alias Domain.Creator.{
    Adventure,
    User
  }

  alias Domain.Creator.Repository.Adventure, as: AdventureRepository
  alias Domain.Creator.Repository.User, as: UserRepository

  def create_creator(creator_id) do
    {:ok, creator} =
      User.new(%{id: creator_id, email: "test@test.com", name: "Test"}, "testtest")
      |> UserRepository.save()

    creator
  end

  def create_adventure(adventure_id, creator_id) do
    {:ok, adventure} =
      Adventure.new(%{
        id: adventure_id,
        creator_id: creator_id,
        name: "test adventure",
        position: %{lat: 70, lng: 80}
      })
      |> AdventureRepository.save()

    adventure
  end

  def add_point(adventure, point_id, parent_point_id) do
    adventure
    |> Adventure.add_point(%{
      id: point_id,
      parent_point_id: parent_point_id,
      position: %{
        lat: 10,
        lng: 10
      },
      radius: 10,
      show: false
    })
    |> AdventureRepository.save()
  end

  def add_clue(adventure, point_id, clue_id) do
    adventure
    |> Adventure.add_clue(%{
      id: clue_id,
      point_id: point_id,
      type: ~w(text audio video image url) |> Enum.random(),
      description: "testtest",
      tip: [true, false] |> Enum.random()
    })
    |> AdventureRepository.save()
  end
end

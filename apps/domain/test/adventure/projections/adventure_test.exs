defmodule Domain.Adventure.Projections.AdventureTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  alias Domain.UserAdventure.Projections.Adventure
  alias Infrastructure.Repository

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository)
  end

  describe "get adventure by id" do
    setup do
      user = insert(:user)
      adventure = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      [adventure_id: adventure.id, user: user]
    end

    test "find adventure by id - adventure exists", %{adventure_id: adventure_id} = context do
      result = Adventure.get_adventure_by_id(%{id: context[:adventure_id]}, %{id: context[:user].id})

      assert {:ok, %{id: ^adventure_id}} = result
    end

    test "find adventure by id - adventure don't exists", context do
      result = Adventure.get_adventure_by_id(%{id: Ecto.UUID.generate()}, %{id: context[:user].id})
      assert {:error, {:adventure, "not_found"}} == result
    end
  end
end

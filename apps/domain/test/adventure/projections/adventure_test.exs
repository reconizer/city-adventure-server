defmodule Domain.Adventure.Projections.AdventureTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  alias Domain.Adventure.Projections.Adventure
  alias Infrastructure.Repository
  
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository)
  end

  describe "get adventure by id" do
    
    setup do
      user_1 = insert(:user)
      user_2 = insert(:user)
      user_3 = insert(:user)
      user_4 = insert(:user)
      user_5 = insert(:user)
      user_6 = insert(:user)
      user_7 = insert(:user)
      adventure = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      [adventure_id: adventure.id]
    end

    test "find adventure by id - adventure exists", context do
      result = Adventure.get_adventure_by_id(%{id: context[:adventure_id]})
      assert result = {:ok, %{id: context[:adventure_id]}} 
    end

    test "find adventure by id - adventure don't exists" do
      result = Adventure.get_adventure_by_id(%{id: Ecto.UUID.generate()})
      assert {:error, {:adventure, "not_found"}} == result
    end

  end

end

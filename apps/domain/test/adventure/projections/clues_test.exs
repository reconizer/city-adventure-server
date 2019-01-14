defmodule Domain.Adventure.Projections.CluesTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  alias Domain.UserAdventure.Projections.Points
  alias Infrastructure.Repository
  
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository)
  end

  describe "clues in adventure listing" do
    
    setup do
      user = insert(:user)
      adventure = insert(:adventure, published: true, show: true)
      point_1 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      point_2 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_1.id)
      insert(:clue, point: point_1)
      insert(:clue, point: point_2)
      insert(:clue, point: point_1)
      insert(:clue, point: point_2)
      insert(:clue, point: point_2)
      insert(:user_point, user: user, point: point_1, completed: true)
      insert(:user_point, user: user, point: point_2)
      insert(:user_adventure, adventure: adventure, user: user)
      [user: user, adventure: adventure]
    end
    
    test "return clues for start point", context do
      result = Points.get_completed_points_with_clues(%{adventure_id: context[:adventure].id}, %{id: context[:user].id})
      assert {:ok, array} = result
      assert Enum.count(array) == 1
    end

    test "return empty array", context do
      result = Points.get_completed_points_with_clues(%{adventure_id: context[:adventure].id}, %{id: Ecto.UUID.generate()})
      assert {:ok, []} == result
    end

  end

end
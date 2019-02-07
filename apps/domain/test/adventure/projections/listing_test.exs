defmodule Domain.Adventure.Projections.ListingTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  alias Domain.UserAdventure.Projections.Listing
  alias Infrastructure.Repository
  
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository)
  end

  describe "adventure listing" do
    setup do
      user = insert(:user)
      adventure_1 = insert(:adventure, published: true, show: true)
      point_1 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_1)
      point_2 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure_1, parent_point_id: point_1.id)
      adventure_2 = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.605892, 53.009062}, srid: 4326}, adventure: adventure_2)
      adventure_3 = insert(:adventure, published: false)
      adventure_4 = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {19.078489, 52.652058}, srid: 4326}, adventure: adventure_4)
      [user: user, adventure_1: adventure_1, adventure_2: adventure_2, adventure_3: adventure_3, adventure_4: adventure_4, point_1: point_1, point_2: point_2]
    end

    test "return adventures", context do
      position = %Geo.Point{coordinates: {18.610177, 53.010744}, srid: 4326}
      {:ok, result} = Listing.get_start_points(%{position: position}, %{id: context[:user].id})
      assert Enum.count(result) == 2 
    end

    test "return adventures, user take a part in adventure", context do
      insert(:user_adventure, adventure: context[:adventure_1], user: context[:user])
      insert(:user_point, point: context[:point_1], user: context[:user])
      position = %Geo.Point{coordinates: {18.610177, 53.010744}, srid: 4326} 
      {:ok, result} = Listing.get_start_points(%{position: position}, %{id: context[:user].id})
      user_adventure = List.first(Enum.filter(result, fn adventure -> 
        adventure.adventure_id == context[:adventure_1].id
      end))
      assert user_adventure.started == true
    end

    test "return adventures, user completed adventure", context do
      insert(:user_adventure, adventure: context[:adventure_1], user: context[:user], completed: true)
      insert(:user_point, point: context[:point_1], user: context[:user], completed: true)
      insert(:user_point, point: context[:point_2], user: context[:user], completed: true)
      position = %Geo.Point{coordinates: {18.610177, 53.010744}, srid: 4326} 
      {:ok, result} = Listing.get_start_points(%{position: position}, %{id: context[:user].id})
      user_adventure = List.first(Enum.filter(result, fn adventure -> 
        adventure.adventure_id == context[:adventure_1].id
      end))
      assert user_adventure.completed == true
    end

  end

end
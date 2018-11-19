defmodule Domain.Adventure.Projections.PointsTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  alias Domain.Adventure.Projections.Points
  alias Infrastructure.Repository
  
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository)
  end

  describe "completed points in adventure" do
    
    setup do
      user = insert(:user)
      adventure = insert(:adventure, published: true, show: true)
      insert(:user_adventure, user: user, adventure: adventure)
      point_1 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      insert(:user_point, user: user, point: point_1, completed: true)
      point_2 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_1.id)
      insert(:user_point, user: user, point: point_2, completed: true)
      point_3 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_2.id)
      insert(:user_point, user: user, point: point_3, completed: true)
      point_4 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_3.id)
      point_5 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_4.id)
      insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_5.id)
      [adventure: adventure, user: user, being_point: point_4]
    end

    test "return completed points without next show point", context do
      {:ok, result} = Points.get_completed_points(%{adventure_id: context[:adventure].id}, %Contract.User.Profile{id: context[:user].id})
      assert Enum.count(result) == 3
    end

    test "return completed points with next show point", context do
      insert(:user_point, user: context[:user], point: context[:being_point], completed: true)
      {:ok, result} = Points.get_completed_points(%{adventure_id: context[:adventure].id}, %Contract.User.Profile{id: context[:user].id})
      assert Enum.count(result) == 4
    end

    test "return empty array", context do
      result = Points.get_completed_points(%{adventure_id: Ecto.UUID.generate()}, %Contract.User.Profile{id: context[:user].id})
      assert result == {:ok, []}
    end

  end

end
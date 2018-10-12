defmodule Domain.Adventure.Projections.AdventureTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  alias Domain.Adventure.Projections.Listing
  alias Infrastructure.Repository
  
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository)
  end

  describe "aventure listing" do
    setup do
      user = insert(:user)
      adventure_1 = insert(:adventure)
      adventure_2 = insert(:adventure, position: %Geo.Point{coordinates: {18.605892, 53.009062}}, srid: 4326}, published: true)
      adventure_3 = insert(:adventure, published: false)
      adventure_4 = insert(:adventure, %Geo.Point{coordinates: {19.078489, 52.652058}})
      [user: user, adventure_1: adventure_1, adventure_2: adventure_2, adventure_3: adventure_3, adventure_4: adventure_4]
    end
    test "return adventures", context do
      position = %Geo.Point{coordinates: {18.610177, 53.010744}, srid: 4326}
      result = Listing.get_start_points(%{position: position}, %{id: context[:user].id})
    end

  end

end
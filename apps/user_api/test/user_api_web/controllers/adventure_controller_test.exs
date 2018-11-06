defmodule UserApiWeb.AdventureControllerTest do
  use ExUnit.Case, async: true
  import Domain.Adventure.Fixtures.Repository
  use UserApiWeb.ConnCase
  alias Infrastructure.Repository
  

  describe "list adventure" do

    setup do
      user = insert(:user)
      adventure = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      adventure_1 = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_1)
      adventure_2 = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_2)
      adventure_3 = insert(:adventure, published: false, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_3)
      [user: user]
    end
    
    test "get adventure list", context do
      conn = %Plug.Conn{}
      conn = get conn, "/adventures"
      assert html_response(conn, 200) =~ "Sign Up"
    end

    # test "get empty array" do
      
    # end

  end


end
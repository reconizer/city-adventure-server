defmodule UserApiWeb.AdventureControllerTest do
  import Domain.Adventure.Fixtures.Repository
  use UserApiWeb.ConnCase  
  use Plug.Test

  describe "list adventure" do

    setup do
      user = insert(:user, nick: "szax", password_digest: "$2b$12$skM3Rg1jb.Ot78PKE.CbD.KukhFTkylYzTCkVWVmNp5dxm4PjVvtO", id: "60781fc0-ddd0-45c2-8972-efa276ecbbe5")
      adventure = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      adventure_1 = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_1)
      adventure_2 = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_2)
      adventure_3 = insert(:adventure, published: false, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure_3)
      [user: user, adventure: adventure_1]
    end
    
    test "get adventure list", %{conn: conn} do
      params = %{
        lat: "53.009870",
        lng: "18.587336"
      }
      conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
      conn = get conn, "/api/adventures/", params
     
      assert Enum.count(json_response(conn, 200)) == 3 
    end

    test "get empty array",  %{conn: conn} do
      params = %{
        lat: "52.880272", 
        lng: "18.791102"
      }
      conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
      conn = get conn, "/api/adventures/", params
     
      assert Enum.count(json_response(conn, 200)) == 0
    end

  end

  describe "show adventure by id" do

    setup do
      user = insert(:user, nick: "szax", password_digest: "$2b$12$skM3Rg1jb.Ot78PKE.CbD.KukhFTkylYzTCkVWVmNp5dxm4PjVvtO", id: "60781fc0-ddd0-45c2-8972-efa276ecbbe5")
      adventure = insert(:adventure, published: true, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      adventure_pub = insert(:adventure, published: false, show: true)
      insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
      [adventure: adventure, user: user, adventure_pub: adventure_pub]
    end
    
    test "- adventure exist", %{conn: conn, adventure: adventure} do
      params = %{
        id: adventure.id
      }
      conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
      conn = get conn, "/api/adventures/#{adventure.id}", params
     
      assert json_response(conn, 200) == adventure 
    end

    test "- adventure don't exist",  %{conn: conn} do
      params = %{
        id: Ecto.UUID.generate()
      }
      conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
      conn = get conn, "/api/adventures/#{Ecto.UUID.generate()}", params
     
      assert json_response(conn, 422) == %{"adventure" => "not_found"}
    end

    # test "- adventure not published",  %{conn: conn} do
    #   params = %{
    #     id: context[:adventure_pub].id
    #   }
    #   conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
    #   conn = get conn, "/api/adventures/:id", params
     
    #   assert json_response(conn, 422) == 0
    # end
    
  end


end
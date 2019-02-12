defmodule UserApiWeb.PointControllerTest do
  import Domain.Adventure.Fixtures.Repository
  use UserApiWeb.ConnCase  
  use Plug.Test

  # describe "list completed points for adventure" do
    
  #   setup do
  #     user = insert(:user, nick: "szax", password_digest: "$2b$12$skM3Rg1jb.Ot78PKE.CbD.KukhFTkylYzTCkVWVmNp5dxm4PjVvtO", id: "60781fc0-ddd0-45c2-8972-efa276ecbbe5")
  #     adventure = insert(:adventure, published: true, show: true)
  #     insert(:user_adventure, user: user, adventure: adventure)
  #     point_1 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
  #     insert(:user_point, user: user, point: point_1, completed: true)
  #     point_2 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_1.id)
  #     insert(:user_point, user: user, point: point_2, completed: true)
  #     point_3 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_2.id)
  #     insert(:user_point, user: user, point: point_3, completed: true)
  #     point_4 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_3.id)
  #     point_5 = insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_4.id)
  #     insert(:point, position: %Geo.Point{coordinates: {18.599245, 53.014637}, srid: 4326}, adventure: adventure, parent_point_id: point_5.id)
  #     [adventure: adventure, user: user, being_point: point_4]
  #   end

  #   test "return completed point - points exists", %{conn: conn, adventure: adventure} do
  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/adventures/#{adventure.id}/completed_points"
  #     assert Enum.count(json_response(conn, 200)) == 3 
  #   end

  #   test "return completed point - with ongoing point", %{conn: conn, being_point: point, user: user, adventure: adventure} do
  #     insert(:user_point, user: user, point: point, completed: true)

  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/adventures/#{adventure.id}/completed_points"
  #     assert Enum.count(json_response(conn, 200)) == 4
  #   end

  # end

end
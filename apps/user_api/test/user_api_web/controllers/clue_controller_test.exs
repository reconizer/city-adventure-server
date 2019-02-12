defmodule UserApiWeb.ClueControllerTest do
  import Domain.Adventure.Fixtures.Repository
  use UserApiWeb.ConnCase
  use Plug.Test

  setup do
    user =
      insert(:user, nick: "szax", password_digest: "$2b$12$skM3Rg1jb.Ot78PKE.CbD.KukhFTkylYzTCkVWVmNp5dxm4PjVvtO", id: "60781fc0-ddd0-45c2-8972-efa276ecbbe5")

    adventure = insert(:adventure, published: true, show: true)
    point_1 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
    point_2 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure, parent_point_id: point_1.id)
    point_3 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure, parent_point_id: point_2.id)
    point_4 = insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure, parent_point_id: point_3.id)
    insert(:clue, point: point_1)
    insert(:clue, point: point_1)
    insert(:clue, point: point_1)
    insert(:clue, point: point_2)
    insert(:clue, point: point_2)
    insert(:clue, point: point_2)
    insert(:clue, point: point_3)
    insert(:clue, point: point_3)
    insert(:clue, point: point_3)
    insert(:clue, point: point_4)
    insert(:clue, point: point_4)
    insert(:clue, point: point_4)
    insert(:user_adventure, adventure: adventure, user: user)
    insert(:user_point, point: point_1, user: user, completed: true)
    insert(:user_point, point: point_2, user: user, completed: true)
    insert(:user_point, point: point_3, user: user, completed: true)
    [adventure: adventure, user: user, point: point_2]
  end

  # describe "list completed clues for adventure" do

  #   test "return clues", %{conn: conn, adventure: adventure} do
  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/clues/#{adventure.id}"
  #     assert Enum.count(json_response(conn, 200)) == 3
  #   end

  #   test "return empty array", %{conn: conn, adventure: _adventure} do
  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/clues/#{Ecto.UUID.generate()}"
  #     assert json_response(conn, 200) == []
  #   end

  # end

  # describe "list clues for point" do

  #   test "return clues", %{conn: conn, adventure: adventure, point: point} do
  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/clues/point/#{adventure.id}/#{point.id}"
  #     assert Enum.count(json_response(conn, 200)) == 3
  #   end

  #   test "return empty array, point_id don't exist", %{conn: conn, adventure: adventure, point: _point} do
  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/clues/point/#{adventure.id}/#{Ecto.UUID.generate()}"
  #     assert json_response(conn, 200) == []
  #   end

  #   test "return empty array, adventure_id don't exist", %{conn: conn, adventure: _adventure, point: point} do
  #     conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
  #     conn = get conn, "/api/clues/point/#{Ecto.UUID.generate()}/#{point.id}"
  #     assert json_response(conn, 200) == []
  #   end

  # end
end

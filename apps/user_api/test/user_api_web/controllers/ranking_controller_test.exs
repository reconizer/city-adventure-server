defmodule UserApiWeb.RankingControllerTest do
  import Domain.Adventure.Fixtures.Repository
  use UserApiWeb.ConnCase  
  use Plug.Test

  setup do
    user_1 = insert(:user, nick: "szax", password_digest: "$2b$12$skM3Rg1jb.Ot78PKE.CbD.KukhFTkylYzTCkVWVmNp5dxm4PjVvtO", id: "60781fc0-ddd0-45c2-8972-efa276ecbbe5")
    user_2 = insert(:user, nick: "ada")
    user_3 = insert(:user, nick: "paul")
    user_4 = insert(:user, nick: "skip")
    user_5 = insert(:user, nick: "luck")
    user_6 = insert(:user, nick: "nit")
    adventure = insert(:adventure, published: true, show: true)
    insert(:point, position: %Geo.Point{coordinates: {18.587336, 53.009870}, srid: 4326}, adventure: adventure)
    insert(:user_adventure, adventure: adventure, user: user_1, completed: true)
    insert(:user_adventure, adventure: adventure, user: user_2, completed: true)
    insert(:user_adventure, adventure: adventure, user: user_3, completed: true)
    insert(:user_adventure, adventure: adventure, user: user_4, completed: true)
    insert(:user_adventure, adventure: adventure, user: user_5, completed: true)
    insert(:user_adventure, adventure: adventure, user: user_6, completed: true)
    insert(:ranking, adventure: adventure, user: user_6, completion_time: "03:49:00")
    insert(:ranking, adventure: adventure, user: user_5, completion_time: "03:25:00")
    insert(:ranking, adventure: adventure, user: user_4, completion_time: "03:31:00")
    insert(:ranking, adventure: adventure, user: user_3, completion_time: "03:49:00")
    insert(:ranking, adventure: adventure, user: user_2, completion_time: "03:59:00")
    insert(:ranking, adventure: adventure, user: user_1, completion_time: "03:19:00")
    [adventure: adventure, user_1: user_1, user_2: user_2, user_3: user_3, user_4: user_4, user_5: user_5, user_6: user_6]
  end

  test "return ranking - limit 10, one page", %{conn: conn, adventure: adventure, user_1: user_1, user_2: user_2, user_3: user_3, user_4: user_4, user_5: user_5, user_6: user_6} do
    conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
    conn = get conn, "/api/adventures/#{adventure.id}/ranking"
    
    result = json_response(conn, 200)
    assert Enum.count(result) == 6 
    assert result = [%{position: 1, user_id: user_1.id}, %{position: 2, user_id: user_5.id}, %{position: 3, user_id: user_4.id}, %{position: 4, user_id: user_6.id}, %{position: 5, user_id: user_3.id}, %{position: 6, user_id: user_2.id}]
  end

  test "return ranking - limit 5, last page", %{conn: conn, adventure: adventure, user_2: user_2} do
    params = %{
      limit: 5,
      page: 2
    }
    conn = conn |> put_req_header("authorization", "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InN6YXgyMkBnbWFpbC5jb20iLCJpZCI6IjYwNzgxZmMwLWRkZDAtNDVjMi04OTcyLWVmYTI3NmVjYmJlNSIsIm5pY2siOiJzemF4In0.ppM6LEulXHqEbFSzs1T2MTtaR8ZJ_dSfX5CaI19D0LU")
    conn = get conn, "/api/adventures/#{adventure.id}/ranking", params
    
    result = json_response(conn, 200)
    assert Enum.count(result) == 1 
    assert result = [%{position: 6, user_id: user_2.id}]
  end

end
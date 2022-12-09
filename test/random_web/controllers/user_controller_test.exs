defmodule RandomWeb.UserControllerTest do
  use RandomWeb.ConnCase

  alias Random.Repo
  alias Random.Users.User

  describe "index/2" do
    test "it responds with users", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get(Routes.user_path(conn, :index))

      assert %{
        "users" => _users,
        "timestamp" => nil
      } = json_response(conn, 200)
    end
  end
end

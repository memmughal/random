defmodule RandomWeb.UserController do
  use RandomWeb, :controller

  alias Random.Worker

  def index(conn, _default) do

   %{last_query_timestamp: last_query_timestamp, users: users} = Worker.get_users()

    conn
    |> put_status(200)
    |> json(%{
      users: users,
      timestamp: last_query_timestamp
    })
  end
end

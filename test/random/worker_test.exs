defmodule WorkerTest do
  use Random.DataCase, async: true

  alias Random.Repo
  alias Random.Schema.User
  alias Random.Worker

  describe "init/1" do
    test "it sets max number in the state" do
      assert {:ok, state} = Worker.init(%{})
      assert %{max_number: new_max_number, last_query_ts: nil} = state
      assert new_max_number in Enum.to_list(0..100)
    end
  end

  describe "handle_call/3" do
    setup do
      Repo.insert(%User{points: 78})
      Repo.insert(%User{points: 40})
      Repo.insert(%User{points: 88})

      :ok
    end

    test "it gets users with points greater than max number" do
      max_number = 70
      last_query_ts = DateTime.utc_now()
      state = %{max_number: max_number, last_query_ts: last_query_ts}

      assert {
        :reply,
        %{
          last_query_timestamp: ^last_query_ts,
          users: users,
        },
        new_state
      } = Worker.handle_call(:get_users, [], state)

      assert Enum.all?(users, & &1.points > max_number)
      assert length(users) == 2
      assert %{last_query_ts: _, max_number: ^max_number} = new_state
    end

    test "it responds with empty users if no users found" do
      max_number = 90
      last_query_ts = DateTime.utc_now()
      state = %{max_number: max_number, last_query_ts: last_query_ts}

      assert {
        :reply,
        %{
          last_query_timestamp: ^last_query_ts,
          users: users,
        },
        _new_state
      } = Worker.handle_call(:get_users, [], state)

      assert users == []
      assert length(users) == 0
    end
  end

  describe "handle_info/2" do
    test "it updates all user points and max number in the state" do
      {:ok, user_1} = Repo.insert(%User{points: 78})
      {:ok, user_2} = Repo.insert(%User{points: 40})

      max_number = 70
      last_query_ts = DateTime.utc_now()
      state = %{max_number: max_number, last_query_ts: last_query_ts}

      assert {:noreply, state} = Worker.handle_info(:update_points, state)
      assert %{max_number: new_max_number, last_query_ts: ^last_query_ts} = state
      refute new_max_number == max_number
      assert new_max_number in Enum.to_list(0..100)

      user_one = Repo.get(User, user_1.id)
      assert user_one.points in Enum.to_list(0..100)

      user_two = Repo.get(User, user_2.id)
      assert user_two.points in Enum.to_list(0..100)
    end
  end
end

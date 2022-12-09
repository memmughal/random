defmodule Random.Worker do
  use GenServer

  alias Random.Users

  @random_min 0
  @random_max 100
  @timeout 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_users do
    GenServer.call(__MODULE__, :get_users, @timeout)
  end

  @impl true
  def init(_state) do
    new_max_number = generate_random_number()
    state = %{max_number: new_max_number, last_query_ts: nil}

    schedule_update_points()

    {:ok, state}
  end

  @impl true
  def handle_call(:get_users, _from, state) do
    last_query_timestamp = state.last_query_ts

    users = state.max_number
    |> Users.get_users()
    |> Enum.map(& %{id: &1.id, points: &1.points})

    timestamp_now = NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_string()

    state = %{state | last_query_ts: timestamp_now}

    {:reply, %{users: users, last_query_timestamp: last_query_timestamp}, state}
  end

  @impl true

  def handle_info(:update_points, state) do

    Task.start(fn -> Users.update_all_points() end)

    new_max_number = generate_random_number()
    state = %{state | max_number: new_max_number}

    schedule_update_points()

    {:noreply, state}
  end

  defp schedule_update_points do
    # Schedule the work to happen in 1 minute
    Process.send_after(self(), :update_points, 60 * 1000)
  end

  defp generate_random_number do
    Enum.random(@random_min..@random_max)
  end
end

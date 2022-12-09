defmodule Random.Users do

  import Ecto.Query

  alias Random.Users.User
  alias Random.Repo

  require Logger

  @batch_size 100_000

  def update_all_points do
    maximum_id = from(u in User, select: max(u.id)) |> Repo.one()

    Logger.info("Starting batch update at #{DateTime.utc_now()}")
    update_range(0, @batch_size, maximum_id)
    Logger.info("Finishing batch update at #{DateTime.utc_now()}")
  end

  def get_users(max_points) do
    from(u in User, where: u.points > ^max_points, limit: 2)
    |> Repo.all()
  end

  defp update_range(start_index, _end_index, maximum_id) when start_index > maximum_id do
    {:ok, :done}
  end

  defp update_range(start_index, end_index, maximum_id) do
    query = from u in User, where: u.id >= ^start_index and u.id < ^end_index

    query
    |> update(set: [points: fragment("floor(random()*101)")])
    |> Repo.update_all([])

    update_range(start_index + @batch_size, end_index + @batch_size, maximum_id)
  end
end

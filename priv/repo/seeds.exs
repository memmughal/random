# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Random.Repo.insert!(%Random.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

Enum.map(1..1_000_000, fn _x -> %{points: 0, inserted_at: now, updated_at: now} end)
|> Enum.chunk_every(20000)
|> Enum.each(fn rows ->
  Ecto.Multi.new()
  |> Ecto.Multi.insert_all(:insert_all, Random.Users.User, rows)
  |> Random.Repo.transaction()
end)

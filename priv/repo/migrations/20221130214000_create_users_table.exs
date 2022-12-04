defmodule Random.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer, default: 0

      timestamps()
    end
  end
end
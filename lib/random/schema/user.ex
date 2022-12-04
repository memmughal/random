defmodule Random.Schema.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :points, :integer, default: 0

    timestamps()
  end

  def changeset(%__MODULE__{} = user, params \\ %{}) do
    user
    |> cast(params, [:points])
    |> validate_required([:points])
    |> validate_inclusion(:points, 0..100)
  end
end

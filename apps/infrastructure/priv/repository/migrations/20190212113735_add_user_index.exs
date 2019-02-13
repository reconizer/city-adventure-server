defmodule Infrastructure.Repository.Migrations.AddUserIndex do
  use Ecto.Migration

  def change do
    create(index(:users, [:email], unique: true))
  end
end

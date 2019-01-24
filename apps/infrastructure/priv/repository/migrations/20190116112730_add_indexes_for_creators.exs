defmodule Infrastructure.Repository.Migrations.AddIndexesForCreators do
  use Ecto.Migration

  def change do
    create(index(:creators, [:email], unique: true))
  end
end

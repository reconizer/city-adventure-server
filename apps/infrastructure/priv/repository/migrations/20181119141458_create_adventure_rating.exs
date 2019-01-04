defmodule Infrastructure.Repository.Migrations.CreateAdventureRating do
  use Ecto.Migration

  def change do
    create table(:adventure_ratings, primary_key: false) do
      add :adventure_id, references(:adventures, [type: :uuid]), null: false
      add :user_id, references(:users, [type: :uuid]), null: false
      add :rating, :integer
      timestamps()
    end
  end
end

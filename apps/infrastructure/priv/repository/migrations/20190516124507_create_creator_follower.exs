defmodule Infrastructure.Repository.Migrations.CreateCreatorFollower do
  use Ecto.Migration

  def change do
    create table(:creator_followers, primary_key: false) do
      add(:creator_id, references(:creators, type: :uuid), null: false)
      add(:user_id, references(:users, type: :uuid), null: false)
      timestamps()
    end
  end
end

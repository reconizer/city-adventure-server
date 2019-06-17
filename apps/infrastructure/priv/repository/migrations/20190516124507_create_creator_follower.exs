defmodule Infrastructure.Repository.Migrations.CreateCreatorFollower do
  use Ecto.Migration

  def change do
    create table(:creator_followers, primary_key: false) do
      add(:creator_id, references(:creators, type: :uuid), null: false)
      add(:user_id, references(:users, type: :uuid), null: false)
      timestamps()
    end

    create_if_not_exists(index(:creator_followers, [:creator_id]))
    create_if_not_exists(index(:creator_followers, [:user_id]))
    create_if_not_exists(unique_index(:creator_followers, [:creator_id, :user_id], name: :uniq_user_and_creator))
  end
end

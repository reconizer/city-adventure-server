defmodule Infrastructure.Repository.Migrations.CreateAdventureMessages do
  use Ecto.Migration

  def change do
    create table(:creator_adventure_messages, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:adventure_id, references(:adventures, type: :uuid), null: false)
      add(:creator_id, references(:creators, type: :uuid), null: false)
      add(:content, :text, null: false)

      timestamps()
    end

    create table(:administrator_adventure_messages, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:adventure_id, references(:adventures, type: :uuid), null: false)
      add(:administrator_id, references(:administrators, type: :uuid), null: false)
      add(:content, :text, null: false)

      timestamps()
    end
  end
end

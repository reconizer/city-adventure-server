defmodule Infrastructure.Repository.Migrations.AddStatusToAdventure do
  use Ecto.Migration

  def change do
    alter table(:adventures) do
      add(:status, :text, null: false, default: "pending")
    end
  end
end

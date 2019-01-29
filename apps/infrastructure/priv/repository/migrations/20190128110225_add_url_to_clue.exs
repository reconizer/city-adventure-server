defmodule Infrastructure.Repository.Migrations.AddStatusToAdventure do
  use Ecto.Migration

  def change do
    alter table(:clues) do
      add(:url, :text)
    end
  end
end

defmodule Infrastructure.Repository.Migrations.AddCreatorIdToAdventure do
  use Ecto.Migration

  def change do
    alter table(:adventures) do
      add :creator_id, references(:creators, [type: :uuid]), null: false
    end
  end
end

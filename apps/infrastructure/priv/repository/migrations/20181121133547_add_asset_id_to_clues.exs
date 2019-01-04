defmodule Infrastructure.Repository.Migrations.AddAssetIdToClues do
  use Ecto.Migration

  def change do
    alter table(:clues) do
      add :asset_id, references(:assets, [type: :uuid])
    end
  end
end

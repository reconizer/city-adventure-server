defmodule Infrastructure.Repository.Migrations.AddAssetIdToCreators do
  use Ecto.Migration

  def change do
    alter table(:creators) do
      add :asset_id, references(:assets, [type: :uuid])
    end
  end
end

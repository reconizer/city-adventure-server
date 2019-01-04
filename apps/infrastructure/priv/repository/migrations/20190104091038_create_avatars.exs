defmodule Infrastructure.Repository.Migrations.CreateAvatars do
  use Ecto.Migration

  def change do
    create table(:avatars, primary_key: false) do
      add :asset_id, references(:assets, [type: :uuid]), null: false
      add :user_id, references(:users, [type: :uuid]), null: false
      timestamps()
    end
  end
end

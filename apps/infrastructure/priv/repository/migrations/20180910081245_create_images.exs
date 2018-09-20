defmodule Infrastructure.Repository.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :adventure_id, references(:adventures, [{:on_delete, :delete_all}, type: :uuid]), null: false

      timestamps()
    end
  end
end

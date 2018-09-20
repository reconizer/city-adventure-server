defmodule Infrastructure.Repository.Migrations.CreateClues do
  use Ecto.Migration

  def change do
    create table(:clues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :description, :text
      add :tip, :boolean
      add :sort, :integer
      add :point_id, references(:points, [{:on_delete, :delete_all}, type: :uuid]), null: false

      timestamps()
    end
  end
end

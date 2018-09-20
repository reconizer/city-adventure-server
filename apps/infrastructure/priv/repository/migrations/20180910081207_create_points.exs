defmodule Infrastructure.Repository.Migrations.CreatePoints do
  use Ecto.Migration

  def change do
    create table(:points, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :show, :boolean
      add :position, :geometry, null: false
      add :radius, :integer, null: false
      add :parent_point_id, references(:points, [type: :uuid])
      add :adventure_id, references(:adventures, [{:on_delete, :delete_all}, type: :uuid]), null: false

      timestamps()
    end

  end
end

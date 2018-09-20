defmodule Infrastructure.Repository.Migrations.CreateUserAdventures do
  use Ecto.Migration

  def change do
    create table(:user_adventures, primary_key: false) do
      add :adventure_id, references(:adventures, [type: :uuid]), null: false
      add :user_id, references(:users, [{:on_delete, :delete_all}, type: :uuid]), null: false
      add :completed, :boolean
      timestamps()
    end
  end
end

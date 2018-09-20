defmodule Infrastructure.Repository.Migrations.CreateUserPoints do
  use Ecto.Migration

  def change do
    create table(:user_points, primary_key: false) do
      add :point_id, references(:points, [type: :uuid]), null: false
      add :user_id, references(:users, [{:on_delete, :delete_all}, type: :uuid]), null: false
      timestamps()
    end
  end
end

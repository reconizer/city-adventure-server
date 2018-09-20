defmodule Infrastructure.Repository.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :details, :map
      add :sort, :integer
      add :point_id, references(:points, [{:on_delete, :delete_all}, type: :uuid]), null: false

      timestamps()
    end

  end
end

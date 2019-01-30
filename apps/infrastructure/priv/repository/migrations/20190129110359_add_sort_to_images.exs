defmodule Infrastructure.Repository.Migrations.AddSortToImages do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :sort, :integer
    end
  end
end

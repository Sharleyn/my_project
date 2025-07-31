defmodule MyProject.Repo.Migrations.CreateStatusesTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :string
    end
  end
end

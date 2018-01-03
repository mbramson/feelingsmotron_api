defmodule Feelingsmotron.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string, null: false
      add :description, :string
      add :owner_id, references(:users, on_delete: :nilify_all), null: false

      timestamps()
    end

    create unique_index(:groups, [:name])

    create table(:user_groups) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:user_groups, [:user_id, :group_id])
  end
end

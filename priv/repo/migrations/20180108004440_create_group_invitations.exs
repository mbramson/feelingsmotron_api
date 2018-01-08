defmodule Feelingsmotron.Repo.Migrations.CreateGroupInvitations do
  use Ecto.Migration

  def change do
    create table(:group_invitations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :from_group, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:group_invitations, [:user_id, :group_id])
  end
end

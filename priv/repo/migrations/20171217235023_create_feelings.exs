defmodule Feelingsmotron.Repo.Migrations.CreateFeelings do
  use Ecto.Migration

  def change do
    create table(:feelings) do
      add :value, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

  end
end

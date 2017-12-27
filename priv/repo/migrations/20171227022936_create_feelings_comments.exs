defmodule Feelingsmotron.Repo.Migrations.CreateFeelingsComments do
  use Ecto.Migration

  def change do
    create table(:feeling_comments) do
      add :text, :text

      timestamps()
    end

    alter table(:feelings) do
      add :comment_id, references(:feeling_comments, on_delete: :nilify_all)
    end
  end
end

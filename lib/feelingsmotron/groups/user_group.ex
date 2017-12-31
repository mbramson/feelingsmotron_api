defmodule Feelingsmotron.Groups.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Groups.UserGroup

  schema "user_groups" do
    belongs_to :user, Feelingsmotron.Account.User
    belongs_to :group, Feelingsmotron.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(%UserGroup{} = user_group, attrs) do
    user_group
    |> cast(attrs, [:user_id, :group_id])
    |> validate_required([:user_id, :group_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:user_id, name: :user_groups_user_id_group_id_index)
  end
end

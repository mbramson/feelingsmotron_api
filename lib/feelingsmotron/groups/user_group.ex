defmodule Feelingsmotron.Groups.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Groups.UserGroup

  schema "user_groups" do
    belongs_to :user, Feelingsmotron.Account.User
    belongs_to :group, Feelingsmotron.Groups.Group
  end

  @doc false
  def changeset(%UserGroup{} = user_group, attrs) do
    user_group
    |> cast(attrs, [:user_id, :group_id])
    |> validate_required([:user_id, :group_id])
  end
end

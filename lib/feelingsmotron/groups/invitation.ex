defmodule Feelingsmotron.Groups.Invitation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Groups.Invitation


  schema "group_invitations" do
    belongs_to :user, Feelingsmotron.Account.User
    belongs_to :group, Feelingsmotron.Groups.Group
    field :from_group, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(%Invitation{} = invitation, attrs) do
    invitation
    |> cast(attrs, [:user_id, :group_id, :from_group])
    |> validate_required([:user_id, :group_id, :from_group])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:group_id)
    |> unique_constraint(:user_id, name: :group_invitations_user_id_group_id_index)
  end
end

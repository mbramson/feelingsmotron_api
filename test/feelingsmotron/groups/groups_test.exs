defmodule Feelingsmotron.GroupsTest do
  use Feelingsmotron.DataCase

  alias Feelingsmotron.Groups
  alias Feelingsmotron.Groups.Group
  alias Feelingsmotron.Groups.UserGroup
  alias Feelingsmotron.Groups.Invitation

  describe "get_group/1" do
    test "returns the group if it does exist" do
      group = insert(:group)
      assert {:ok, returned_group} = Groups.get_group(group.id)
      assert returned_group.id == group.id
    end

    test "returns an error tuple when id is nil" do
      assert Groups.get_group(nil) == {:error, :bad_request}
    end

    test "returns an error tuple when id is an empty string" do
      assert Groups.get_group("") == {:error, :bad_request} end

    test "returns an error tuple when the group does not exist" do
      assert Groups.get_group(999) == {:error, :not_found}
    end
  end

  describe "get_group_with_users/1" do
    test "returns the group if it does exist" do
      user_in_group = insert(:user)
      owner = insert(:user)
      group = insert(:group, %{owner: owner, users: [user_in_group]})

      assert {:ok, returned_group} = Groups.get_group_with_users(group.id)
      assert returned_group.id == group.id
      assert returned_group.owner.id == owner.id
      assert [returned_user_in_group | []] = returned_group.users
      assert returned_user_in_group.id == user_in_group.id
    end

    test "returns an error tuple when the group does not exist" do
      assert Groups.get_group_with_users(999) == {:error, :not_found}
    end
  end

  describe "list_all/0" do
    test "lists all existing groups" do
      assert Groups.list_all() |> length == 0

      insert(:group)
      assert Groups.list_all() |> length == 1

      insert(:group)
      assert Groups.list_all() |> length == 2
    end
  end

  describe "create_group/2" do
    test "creates a group with the correct owner" do
      user = insert(:user)
      attrs = %{name: "group_name", description: "desc", owner_id: user.id}
      assert {:ok, group} = Groups.create_group(attrs)
      assert group.owner_id == user.id
      assert group.name == "group_name"
      assert group.description == "desc"
      assert Repo.all(Groups.Group) |> length == 1
    end

    test "creates a group with the given members in the users parameter" do
      [owner, member1, member2] = insert_list(3, :user)
      users = [member1, member2]
      attrs = %{name: "group_name", description: "desc", owner_id: owner.id, users: users}
      assert {:ok, group} = Groups.create_group(attrs)

      assert {:ok, group} = Groups.get_group_with_users(group.id)
      assert group.users |> length == 2
      assert [returned_user1, returned_user2] = Enum.sort(group.users)
      assert returned_user1.id == member1.id
      assert returned_user2.id == member2.id
    end

    test "fails if the associated user does not exist" do
      attrs = %{name: "group_name", description: "desc", owner_id: 999}
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(attrs)
    end

    test "fails if the group name is invalid" do
      user = insert(:user)
      attrs = %{name: 999, description: "desc", owner_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(attrs)
    end

    test "fails if the group description is invalid" do
      user = insert(:user)
      attrs = %{name: "group_name", description: 999, owner_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(attrs)
    end

    test "fails if the user id is invalid" do
      attrs = %{name: "group_name", description: "desc", owner_id: "invalid"}
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(attrs)
    end
  end

  describe "updated_group/2" do
    test "updates the given group" do
      group = insert(:group)
      assert {:ok, updated_group} = Groups.update_group(group, %{name: "new_name"})
      assert updated_group.name == "new_name"
      assert Repo.get(Group, group.id).name == "new_name"
    end

    test "fails if invalid attributes are given" do
      group = insert(:group)
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, %{name: 999})
    end
  end

  describe "delete_group/2" do
    test "succeeds when the deleting user is the group owner" do
      owner = insert(:user)
      group = insert(:group, %{owner: owner})
      assert {:ok, group} = Groups.delete_group(group, owner)
      assert %Group{} = group
    end

    test "fails if the deleting user is not the group owner" do
      not_owner = insert(:user)
      group = insert(:group)
      assert {:error, :forbidden} = Groups.delete_group(group, not_owner)
    end

    test "fails if the deleting user does not exist" do
      group = insert(:group)
      assert {:error, :not_found} = Groups.delete_group(group, 999)
    end

    test "fails if the group does not exist" do
      user = insert(:group)
      assert {:error, :not_found} = Groups.delete_group(999, user)
    end
  end

  describe "get_user_group_by_user_and_group/2" do
    test "returns a user group if it exists" do
      user = insert(:user)
      group = insert(:group)
      insert(:user_group, %{user: user, group: group})
      assert {:ok, user_group}
        = Groups.get_user_group_by_user_and_group(user.id, group.id)

      assert user_group.user_id == user.id
      assert user_group.group_id == group.id
    end

    test "returns an error tuple if the user_group does not exist" do
      assert {:error, :not_found} = Groups.get_user_group_by_user_and_group(999, 999)
    end
  end

  describe "add_user_to_group/2" do
    test "adds a user to the group" do
      user = insert(:user)
      group = insert(:group)
      assert {:ok, user_group} = Groups.add_user_to_group(user, group)
      assert %UserGroup{} = user_group
      assert user_group.user_id == user.id
      assert user_group.group_id == group.id
    end

    test "fails if the user does not exist" do
      group = insert(:group)
      assert {:error, %Ecto.Changeset{}} = Groups.add_user_to_group(999, group)
    end

    test "fails if the group does not exist" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Groups.add_user_to_group(user, 999)
    end

    test "fails if the user is already in the group" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})
      assert {:error, %Ecto.Changeset{}} = Groups.add_user_to_group(user, group)
    end
  end

  describe "list_users_invitations/1" do
    test "returns all invitations associated with a user" do
      user = insert(:user)
      insert(:group_invitation, %{user: user, from_group: false})
      insert(:group_invitation, %{user: user, from_group: true})

      assert {:ok, [%Invitation{}, %Invitation{}]} = Groups.list_users_invitations(user.id)
    end

    test "returns an empty list if no invitations are found" do
      assert {:ok, []} = Groups.list_users_invitations(999)
    end

    test "does not return another user's invitations" do
      user = insert(:user)
      other_user = insert(:user)
      insert(:group_invitation, %{user: other_user})

      assert {:ok, []} = Groups.list_users_invitations(user.id)
    end
  end

  describe "get_invitation_with_group/1" do
    test "returns the invitation with the group preloaded if it exists" do
      invitation = insert(:group_invitation)
      assert {:ok, returned_invitation} = Groups.get_invitation_with_group(invitation.id)
      assert Ecto.assoc_loaded? returned_invitation.group
    end

    test "returns an error tuple if the invitation does not exist" do
      assert {:error, :not_found} = Groups.get_invitation_with_group(999)
    end
  end

  describe "create_group_invitation/3" do
    test "creates an invitation from the group" do
      user = insert(:user)
      group = insert(:group)
      assert {:ok, invite} = Groups.create_group_invitation(user.id, group.id, true)
      assert invite.from_group == true
      assert invite.group_id == group.id
      assert invite.user_id == user.id
    end

    test "returns an error if the user doesn't exist" do
      group = insert(:group)
      assert {:error, %Ecto.Changeset{}} = Groups.create_group_invitation(999, group.id, true)
    end

    test "returns an error if the group doesn't exist" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Groups.create_group_invitation(user.id, 999, true)
    end

    test "returns an error if the user is already in the group" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})
      assert {:error, {:conflict, "User already in group"}} = Groups.create_group_invitation(user.id, group.id, true)
    end

    test "returns an error for invalid input" do
      assert {:error, :bad_request} = Groups.create_group_invitation("", 999, true)
      assert {:error, :bad_request} = Groups.create_group_invitation(nil, 999, true)
      assert {:error, :bad_request} = Groups.create_group_invitation(999, "", true)
      assert {:error, :bad_request} = Groups.create_group_invitation(999, nil, true)
    end
  end

  describe "delete_group_invitation/1" do
    test "deletes an invitation" do
      invitation = insert(:group_invitation)
      assert {:ok, _deleted_invitation} = Groups.delete_group_invitation(invitation.id)
      assert [] = Repo.all(Invitation)
    end

    test "returns an error tuple if the invitation does not exist" do
      assert {:error, :not_found} = Groups.delete_group_invitation(999)
    end
  end

  describe "confirm_group_invitation/1" do
    test "deletes the invitation and adds the user to the group" do
      invitation = insert(:group_invitation)

      assert {:ok, %{group_invitation: _, user_group: _}} = Groups.confirm_group_invitation(invitation)

      refute Repo.get(Invitation, invitation.id)
      assert Repo.get_by(UserGroup, user_id: invitation.user.id, group_id: invitation.group.id)
    end

    test "deletes the invitation if the user is already in the group" do
      invitation = insert(:group_invitation)
      insert(:user_group, %{user: invitation.user, group: invitation.group})

      assert {:ok, %{group_invitation: _, user_group: _}} = Groups.confirm_group_invitation(invitation)

      refute Repo.get(Invitation, invitation.id)
    end

    test "returns an error tuple if the invitation does not exist" do
      assert {:error, :not_found} = Groups.confirm_group_invitation(999)
    end
  end

  describe "user_can_manage_group_membership/2" do
    test "user can invite for group if they are the group's owner" do
      user = insert(:user)
      group = insert(:group, %{owner: user})
      assert :ok = Groups.user_can_manage_group_membership(user.id, group)
    end

    test "group members cannot invite for group if they are not owners" do
      user = insert(:user)
      group = insert(:group, %{users: [user]})
      assert {:error, :forbidden} = Groups.user_can_manage_group_membership(user.id, group)
    end

    test "non associated users cannot invite for group" do
      user = insert(:user)
      group = insert(:group)
      assert {:error, :forbidden} = Groups.user_can_manage_group_membership(user.id, group)
    end

    test "returns error tuple if given non-existent group id" do
      user = insert(:user)
      assert {:error, :not_found} = Groups.user_can_manage_group_membership(user.id, 999)
    end

    test "returns error tuple if user_id or group_id are invalid" do
      user = insert(:user)
      group = insert(:group)
      assert {:error, :bad_request} = Groups.user_can_manage_group_membership("", group.id)
      assert {:error, :bad_request} = Groups.user_can_manage_group_membership(nil, group.id)
      assert {:error, :bad_request} = Groups.user_can_manage_group_membership(user.id, "")
      assert {:error, :bad_request} = Groups.user_can_manage_group_membership(user.id, nil)
    end
  end
end

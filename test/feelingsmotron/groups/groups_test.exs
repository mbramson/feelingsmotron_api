defmodule Feelingsmotron.GroupsTest do
  use Feelingsmotron.DataCase

  alias Feelingsmotron.Groups
  alias Feelingsmotron.Groups.Group
  alias Feelingsmotron.Groups.UserGroup

  describe "get_group/1" do
    test "returns the group if it does exist" do
      group = insert(:group)
      assert {:ok, returned_group} = Groups.get_group(group.id)
      assert returned_group.id == group.id
    end

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
      assert {:ok, group} = Groups.create_group("group_name", user)
      assert group.owner_id == user.id
      assert group.name == "group_name"
      assert Repo.all(Groups.Group) |> length == 1
    end

    test "fails if the associated user does not exist" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group("group_name", 999)
    end

    test "fails if the group name is invalid" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(999, user)
    end

    test "fails if the user id is invalid" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group("group_name", "invalid")
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
end

defmodule Feelingsmotron.GroupsTest do
  use Feelingsmotron.DataCase

  alias Feelingsmotron.Groups
  alias Feelingsmotron.Groups.Group

  describe "get_group/1" do
    test "returns nil when the group does not exist" do
      assert Groups.get_group(999) == nil
    end

    test "returns the group if it does exist" do
      group = insert(:group)
      returned_group = Groups.get_group(group.id)
      assert returned_group.id == group.id
    end
  end

  describe "list_groups/0" do
    test "lists all existing groups" do
      assert Groups.list_groups() |> length == 0

      insert(:group)
      assert Groups.list_groups() |> length == 1

      insert(:group)
      assert Groups.list_groups() |> length == 2
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
      assert {:error, _} = Groups.create_group("group_name", 999)
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
end

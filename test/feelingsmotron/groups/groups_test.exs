defmodule Feelingsmotron.GroupsTest do
  use Feelingsmotron.DataCase

  alias Feelingsmotron.Groups

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
    test "fails if the associated user does not exist" do
      assert {:error, _} = Groups.create_group("group_name", 999)
    end

    test "creates a group with the correct owner" do
      user = insert(:user)
      assert {:ok, group} = Groups.create_group("group_name", user)
      assert group.owner_id == user.id
      assert group.name == "group_name"
      assert Repo.all(Groups.Group) |> length == 1
    end
  end
end

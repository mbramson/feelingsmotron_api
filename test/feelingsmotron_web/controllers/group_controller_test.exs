defmodule FeelingsmotronWeb.GroupControllerTest do
  use FeelingsmotronWeb.ConnCase

  describe "index" do
    test "lists the groups that exist ordered by name" do
      {conn, _user} = conn_with_authenticated_user()

      insert(:group, name: "zeta")
      insert(:group, name: "alpha")

      conn = get conn, group_path(conn, :index), %{}

      assert %{"groups" => groups} = json_response(conn, 200)
      assert [first, second | []] = groups
      assert first["name"] == "alpha"
      assert second["name"] == "zeta"
    end

    test "returns an empty list of groups if none exist" do
      {conn, _user} = conn_with_authenticated_user()
      conn = get conn, group_path(conn, :index), %{}

      assert %{"groups" => []} = json_response(conn, 200)
    end
  end

  describe "show" do
    test "returns a single group" do
      {conn, _user} = conn_with_authenticated_user()
      group = insert(:group)

      conn = get conn, group_path(conn, :show, group.id), %{}

      assert response = json_response(conn, 200)
      assert response["id"] == group.id
      assert response["name"] == group.name
      assert response["description"] == group.description
    end

    test "returns the owner and users of the group" do
      {conn, _user} = conn_with_authenticated_user()
      owner = insert(:user)
      user_in_group = insert(:user)
      group = insert(:group, %{owner: owner, users: [user_in_group]})

      conn = get conn, group_path(conn, :show, group.id), %{}

      assert response = json_response(conn, 200)
      assert response["owner"]["id"] == owner.id
      assert response["owner"]["name"] == owner.name

      assert [returned_user_response | []] = response["users"]
      assert returned_user_response["id"] == user_in_group.id
      assert returned_user_response["name"] == user_in_group.name
    end

    test "returns an empty list of groups if none exist" do
      {conn, _user} = conn_with_authenticated_user()
      conn = get conn, group_path(conn, :show, 999), %{}

      assert %{"errors" => _} = json_response(conn, 404)
    end
  end

  describe "create" do
    test "creates a group with the current user as the owner" do
      {conn, user} = conn_with_authenticated_user()
      attrs = %{name: "cat group", description: "group for cats"}
      conn = post conn, group_path(conn, :create), %{group: attrs}

      assert response = json_response(conn, 200)
      assert response["name"] == "cat group"

      assert [group | []] = Feelingsmotron.Groups.list_all()
      assert group.name == "cat group"
      assert group.description == "group for cats"
      assert group.owner_id == user.id
    end

    test "creates a group with the creator as a member" do
      {conn, user} = conn_with_authenticated_user()
      attrs = %{name: "cat group", description: "group for cats"}
      conn = post conn, group_path(conn, :create), %{group: attrs}

      assert response = json_response(conn, 200)

      {:ok, group} = Feelingsmotron.Groups.get_group_with_users(response["id"])

      assert [member | []] = group.users
      assert member.id == user.id
    end

    test "returns an error for invalid parameters" do
      {conn, _user} = conn_with_authenticated_user()
      conn = post conn, group_path(conn, :create), %{group: %{}}
      assert %{"errors" => _} = json_response(conn, 422)
    end
  end

  describe "non-authenticated requests" do
    test "non-authenticated :index returns 403", %{conn: conn} do
      conn = get conn, group_path(conn, :index), %{}
      assert text_response(conn, 403)
    end
  end
end

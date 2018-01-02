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

  describe "non-authenticated requests" do
    test "non-authenticated :index returns 403", %{conn: conn} do
      conn = get conn, group_path(conn, :index), %{}
      assert text_response(conn, 403)
    end
  end
end

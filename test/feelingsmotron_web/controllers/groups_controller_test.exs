defmodule FeelingsmotronWeb.GroupsControllerTest do
  use FeelingsmotronWeb.ConnCase

  describe "index" do
    test "lists the groups that exist ordered by name" do
      {conn, _user} = conn_with_authenticated_user()

      insert(:group, name: "zeta")
      insert(:group, name: "alpha")

      conn = get conn, groups_path(conn, :index), %{}

      assert %{"groups" => groups} = json_response(conn, 200)
      assert [first, second | []] = groups
      assert first["name"] == "alpha"
      assert second["name"] == "zeta"
    end

    test "returns an empty list of groups if none exist" do
      {conn, _user} = conn_with_authenticated_user()
      conn = get conn, groups_path(conn, :index), %{}

      assert %{"groups" => []} = json_response(conn, 200)
    end
  end

  describe "non-authenticated requests" do
    test "non-authenticated :index returns 403", %{conn: conn} do
      conn = get conn, groups_path(conn, :index), %{}
      assert text_response(conn, 403)
    end
  end
end

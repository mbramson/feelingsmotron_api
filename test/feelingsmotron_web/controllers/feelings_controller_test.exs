defmodule FeelingsmotronWeb.FeelingsControllerTest do
  use FeelingsmotronWeb.ConnCase

  describe "show" do
    test "returns no feeling if none exists" do
      {conn, _user} = conn_with_authenticated_user()

      conn = get conn, feelings_path(conn, :show)
      assert %{"feelings" => nil} = json_response(conn, 200)
    end

    test "returns no feeling if none exists for the logged in user" do
      {conn, _user} = conn_with_authenticated_user()
      other_user = insert(:user)
      insert(:feeling, %{user: other_user})

      conn = get conn, feelings_path(conn, :show)
      assert %{"feelings" => nil} = json_response(conn, 200)
    end

    test "returns a feeling if one exists for the logged in user" do
      {conn, user} = conn_with_authenticated_user()
      feeling = insert(:feeling, %{user: user})

      conn = get conn, feelings_path(conn, :show)
      value = feeling.value
      assert %{"feelings" => ^value} = json_response(conn, 200)
    end

    test "returns the last feeling if multiple exist for the logged in user" do
      {conn, user} = conn_with_authenticated_user()
      insert(:feeling, %{user: user, value: 1})
      insert(:feeling, %{user: user, value: 2})

      conn = get conn, feelings_path(conn, :show)
      assert %{"feelings" => 2} = json_response(conn, 200)

    end
  end

  describe "create" do

  end
end

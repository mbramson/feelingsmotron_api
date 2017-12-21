defmodule FeelingsmotronWeb.FeelingsControllerTest do
  use FeelingsmotronWeb.ConnCase

  alias Feelingsmotron.Feelings

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
    test "adds a new feeling" do
      {conn, user} = conn_with_authenticated_user()
      post conn, feelings_path(conn, :create), %{feelings: 1}

      assert [feeling | []] = Feelings.list_feelings
      assert feeling.user_id == user.id
    end

    test "errors when given an invalid feeling" do
      {conn, _user} = conn_with_authenticated_user()
      conn = post conn, feelings_path(conn, :create), %{feelings: 0}
      assert json_response(conn, 422)

      {conn, _user} = conn_with_authenticated_user()
      conn = post conn, feelings_path(conn, :create), %{feelings: 6}
      assert json_response(conn, 422)

      {conn, _user} = conn_with_authenticated_user()
      conn = post conn, feelings_path(conn, :create), %{feelings: "cats"}
      assert json_response(conn, 422)
    end
  end

  describe "non-authenticated requests" do
    test "non-authenticated :show returns 403", %{conn: conn} do
      conn = post conn, feelings_path(conn, :create), %{feelings: 1}
      assert text_response(conn, 403)
    end

    test "non-authenticated :create returns 403", %{conn: conn} do
      conn = post conn, feelings_path(conn, :create), %{feelings: 1}
      assert text_response(conn, 403)
    end
  end
end

defmodule FeelingsmotronWeb.GroupInvitationControllerTest do
  use FeelingsmotronWeb.ConnCase

  alias Feelingsmotron.Repo
  alias Feelingsmotron.Groups.Invitation
  alias Feelingsmotron.Groups.UserGroup

  describe "index" do
    test "renders a list of invitations with the group information" do
      {conn, user} = conn_with_authenticated_user()
      insert(:group_invitation, %{user: user})
      insert(:group_invitation, %{user: user})

      conn = get conn, group_invitation_path(conn, :index), %{}
      assert response = json_response(conn, 200)
      assert [invitation1, invitation2] = response["group_invitations"]
      assert invitation1["user_id"] == user.id
      assert invitation2["user_id"] == user.id
    end

    test "renders a successful response even if no invitations are found" do
      {conn, _user} = conn_with_authenticated_user()
      conn = get conn, group_invitation_path(conn, :index), %{}
      assert response = json_response(conn, 200)
      assert [] = response["group_invitations"]
    end
  end

  describe "create when from_group is true" do
    test "creates an invite if the current user owns the group" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group, %{owner: user})
      other_user = insert(:user)

      attrs = %{"user_id" => other_user.id, "group_id" => group.id, "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert response = json_response(conn, 201)
      assert response["group_invitation"]["user_id"] == other_user.id
      assert response["group_invitation"]["group_id"] == group.id
      assert response["group_invitation"]["from_group"] == true

      [group_invitation | []] = Repo.all(Invitation)
      assert group_invitation.user_id == other_user.id
      assert group_invitation.group_id == group.id
      assert group_invitation.from_group == true
    end

    test "errors if the current user does not own the group" do
      {conn, _user} = conn_with_authenticated_user()
      group = insert(:group)
      other_user = insert(:user)

      attrs = %{"user_id" => other_user.id, "group_id" => group.id, "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}
      assert json_response(conn, 403)
    end

    test "errors if the current user does not own the group and invites themself" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group)

      attrs = %{"user_id" => user.id, "group_id" => group.id, "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}
      assert json_response(conn, 403)
    end

    test "errors if user is already in the group" do
      {conn, user} = conn_with_authenticated_user()
      other_user = insert(:user)
      group = insert(:group, %{owner: user, users: [other_user]})

      attrs = %{"user_id" => other_user.id, "group_id" => group.id, "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert response = json_response(conn, 409)
      assert response["data"]["message"] == "User already in group"
    end

    test "errors if params are invalid" do
      {conn, _user} = conn_with_authenticated_user()

      attrs = %{"user_id" => "", "group_id" => "", "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}
      assert json_response(conn, 400)
    end

    test "errors if user does not exist" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group, %{owner: user})

      attrs = %{"user_id" => 999, "group_id" => group.id, "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert json_response(conn, 404)
    end

    test "errors if group does not exist" do
      {conn, _user} = conn_with_authenticated_user()
      other_user = insert(:user)

      attrs = %{"user_id" => other_user.id, "group_id" => 999, "from_group" => "true"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert json_response(conn, 404)
    end

    test "errors if the from_group param is not boolean" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group, %{owner: user})
      other_user = insert(:user)

      attrs = %{"user_id" => other_user.id, "group_id" => group.id, "from_group" => 999}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert json_response(conn, 400)
    end
  end

  describe "create when from_group is false" do
    test "creates an invite if the current user is the user in params" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group)

      attrs = %{"user_id" => user.id, "group_id" => group.id, "from_group" => "false"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert response = json_response(conn, 201)
      assert response["group_invitation"]["user_id"] == user.id
      assert response["group_invitation"]["group_id"] == group.id
      assert response["group_invitation"]["from_group"] == false

      [group_invitation | []] = Repo.all(Invitation)
      assert group_invitation.user_id == user.id
      assert group_invitation.group_id == group.id
      assert group_invitation.from_group == false
    end

    test "errors if the user in params is not the current user" do
      {conn, _user} = conn_with_authenticated_user()
      group = insert(:group)
      other_user = insert(:user)

      attrs = %{"user_id" => other_user.id, "group_id" => group.id, "from_group" => "false"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert json_response(conn, 403)
    end

    test "errors if the user is already in the group" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group, %{users: [user]})

      attrs = %{"user_id" => user.id, "group_id" => group.id, "from_group" => "false"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert response = json_response(conn, 409)
      assert response["data"]["message"] == "User already in group"
    end

    test "errors if user does not exist" do
      {conn, _user} = conn_with_authenticated_user()
      group = insert(:group)

      attrs = %{"user_id" => 999, "group_id" => group.id, "from_group" => "false"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert json_response(conn, 404)
    end

    test "errors if group does not exist" do
      {conn, user} = conn_with_authenticated_user()

      attrs = %{"user_id" => user.id, "group_id" => 999, "from_group" => "false"}
      conn = post conn, group_invitation_path(conn, :create), %{group_invitation: attrs}

      assert json_response(conn, 404)
    end
  end

  describe "update when invitation is from the group" do
    test "deletes the invitation and adds the user to the group if current user is that user" do
      {conn, user} = conn_with_authenticated_user()
      invitation = insert(:group_invitation, %{user: user, from_group: true})

      conn = put conn, group_invitation_path(conn, :update, invitation.id), %{}

      assert response = json_response(conn, 200)
      assert response["group_invitation"]["id"] == invitation.id
      assert response["group_invitation"]["group_id"] == invitation.group_id
      assert response["group_invitation"]["user_id"] == invitation.user_id
      assert response["user_group"]["user_id"] == invitation.user_id
      assert response["user_group"]["group_id"] == invitation.group_id

      refute Repo.get(Invitation, invitation.id)
      assert Repo.get_by(UserGroup, %{user_id: user.id, group_id: invitation.group.id})
    end
  end

  describe "delete" do
    test "deletes the group invitation if it is associated with current user" do
      {conn, user} = conn_with_authenticated_user()
      invitation = insert(:group_invitation, %{user: user})

      conn = delete conn, group_invitation_path(conn, :delete, invitation.id), %{}

      assert json_response(conn, 200)
      refute Repo.get(Invitation, invitation.id)
    end

    test "deletes the group invitation if current user is associated group owner" do
      {conn, user} = conn_with_authenticated_user()
      group = insert(:group, %{owner: user})
      invitation = insert(:group_invitation, %{group: group})

      conn = delete conn, group_invitation_path(conn, :delete, invitation.id), %{}

      assert json_response(conn, 200)
      refute Repo.get(Invitation, invitation.id)
    end

    test "does not delete the group invitation if current user is not associated" do
      {conn, _user} = conn_with_authenticated_user()
      invitation = insert(:group_invitation)

      conn = delete conn, group_invitation_path(conn, :delete, invitation.id), %{}

      assert json_response(conn, 403)
    end
  end

  describe "non-authenticated requests" do
    test "non-authenticated :index returns 403", %{conn: conn} do
      conn = get conn, group_invitation_path(conn, :index), %{}
      assert text_response(conn, 403)
    end

    test "non-authenticated :create returns 403", %{conn: conn} do
      conn = post conn, group_invitation_path(conn, :create), %{}
      assert text_response(conn, 403)
    end

    test "non-authenticated :delete returns 403", %{conn: conn} do
      conn = delete conn, group_invitation_path(conn, :delete, 999), %{}
      assert text_response(conn, 403)
    end
  end
end

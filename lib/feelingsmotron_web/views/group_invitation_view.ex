defmodule FeelingsmotronWeb.GroupInvitationView do
  use FeelingsmotronWeb, :view

  alias FeelingsmotronWeb.GroupInvitationView
  alias FeelingsmotronWeb.GroupView
  alias FeelingsmotronWeb.UserGroupView

  def render("index.json", %{group_invitations: invitations}) do
    %{group_invitations: render_many(invitations, GroupInvitationView, "group_invitation_with_group.json")}
  end

  def render("show.json", %{group_invitation: group_invitation}) do
    %{group_invitation: render_one(group_invitation, GroupInvitationView, "group_invitation.json")}
  end

  def render("group_invitation.json", %{group_invitation: invitation}) do
    %{id: invitation.id,
      user_id: invitation.user_id,
      group_id: invitation.group_id,
      from_group: invitation.from_group}
  end

  def render("group_invitation_with_group.json", %{group_invitation: invitation}) do
    %{id: invitation.id,
      user_id: invitation.user_id,
      group: render_one(invitation.group, GroupView, "group.json"),
      group_id: invitation.group_id,
      from_group: invitation.from_group}
  end

  def render("update.json", %{transaction: %{group_invitation: invitation, user_group: user_group}}) do
    %{group_invitation: render_one(invitation, GroupInvitationView, "group_invitation.json"),
      user_group: render_one(user_group, UserGroupView, "user_group.json")}
  end
end

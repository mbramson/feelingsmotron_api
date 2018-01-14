defmodule FeelingsmotronWeb.GroupInvitationView do
  use FeelingsmotronWeb, :view

  alias FeelingsmotronWeb.GroupInvitationView

  def render("show.json", %{group_invitation: group_invitation}) do
    %{group_invitation: render_one(group_invitation, GroupInvitationView, "group_invitation.json")}
  end

  def render("group_invitation.json", %{group_invitation: group_invitation}) do
    %{id: group_invitation.id,
      user_id: group_invitation.user_id,
      group_id: group_invitation.group_id,
      from_group: group_invitation.from_group}
  end
end

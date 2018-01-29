defmodule FeelingsmotronWeb.UserGroupView do
  use FeelingsmotronWeb, :view

  def render("user_group.json", %{user_group: user_group}) do
    %{id: user_group.id,
      user_id: user_group.user_id,
      group_id: user_group.group_id}
  end
end

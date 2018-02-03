defmodule FeelingsmotronWeb.GroupView do
  use FeelingsmotronWeb, :view

  alias FeelingsmotronWeb.GroupView
  alias FeelingsmotronWeb.UserView

  def render("index.json", %{groups: groups}) do
    %{groups: render_many(groups, GroupView, "group.json")}
  end

  def render("show.json", %{group: group}) do
    %{group: render_one(group, GroupView, "group.json")}
  end

  def render("show_with_users.json", %{group: group}) do
    %{group: render_one(group, GroupView, "group_with_users.json")}
  end

  def render("group.json", %{group: group}) do
    %{id: group.id,
      description: group.description,
      name: group.name}
  end

  def render("group_with_users.json", %{group: group}) do
    %{id: group.id,
      name: group.name,
      description: group.description,
      owner: render_one(group.owner, UserView, "user.json"),
      users: render_many(group.users, UserView, "user.json")}
  end
end

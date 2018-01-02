defmodule FeelingsmotronWeb.GroupsView do
  use FeelingsmotronWeb, :view

  alias Feelingsmotron.Groups.Group
  alias FeelingsmotronWeb.GroupsView

  def render("index.json", %{groups: groups}) do
    %{groups: render_many(groups, GroupsView, "group.json")}
  end

  def render("group.json", %{groups: group}) do
    %{id: group.id,
      name: group.name}
  end
end

defmodule FeelingsmotronWeb.GroupController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Groups

  def index(conn, _params) do
    groups = Groups.list_all()
    render(conn, "index.json", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, group} <- Groups.get_group_with_users(id), do:
      render(conn, "show.json", group: group)
  end
end

defmodule FeelingsmotronWeb.GroupsController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Groups

  def index(conn, _params) do
    groups = Groups.list_all()
    render(conn, "index.json", groups: groups)
  end
end

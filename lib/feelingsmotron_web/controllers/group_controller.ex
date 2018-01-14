defmodule FeelingsmotronWeb.GroupController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Groups

  def index(conn, _params) do
    groups = Groups.list_all()
    render(conn, "index.json", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    with {:ok, group} <- Groups.get_group_with_users(id, current_user.id), do:
      render(conn, "show.json", group: group)
  end

  def create(conn, %{"group" => group_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    group_params = group_params
      |> Map.put("owner_id", current_user.id)
      |> Map.put("users", [current_user])

    with {:ok, group} <- Groups.create_group(group_params), do:
      render(conn, "group.json", group: group)
  end

  def update(conn, %{"id" => group_id, "group" => group_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    with {:ok, group} <- Groups.get_group(group_id),
         :ok <- validate_allowed_to_update_group(current_user, group),
         {:ok, group} <- Groups.update_group(group, group_params) do
      render(conn, "group.json", group: group)
    end
  end

  @spec validate_allowed_to_update_group(Types.user, Types.group) :: :ok | {:error, :forbidden}
  defp validate_allowed_to_update_group(user, group) do
    if group.owner_id == user.id do
      :ok
    else
      {:error, :forbidden}
    end
  end
end

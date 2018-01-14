defmodule FeelingsmotronWeb.GroupInvitationController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Groups

  def create(conn, %{"group_invitation" =>
    %{"user_id" => user_id, "group_id" => group_id, "from_group" => "true"}}) do

    current_user = Guardian.Plug.current_resource(conn)
    with :ok <- Groups.user_can_invite_for_group(current_user.id, group_id),
         {:ok, invitation} <- Groups.create_group_invitation(user_id, group_id, true) do
      conn
      |> put_status(:created)
      |> render("show.json", group_invitation: invitation)
    end
  end
  def create(conn, %{"group_invitation" =>
    %{"user_id" => user_id, "group_id" => group_id, "from_group" => "false"}}) do

    current_user = Guardian.Plug.current_resource(conn)
    with :ok <- validate_same_id(current_user.id, user_id),
         {:ok, invitation} <- Groups.create_group_invitation(user_id, group_id, false) do
      conn
      |> put_status(:created)
      |> render("show.json", group_invitation: invitation)
    end
  end
  def create(conn, _params), do: {:error, :bad_request}

  @spec validate_same_id(any(), any()) :: :ok | {:error, :forbidden}
  defp validate_same_id(id, id) when is_integer(id), do: :ok
end

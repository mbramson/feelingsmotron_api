defmodule FeelingsmotronWeb.GroupInvitationController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Account
  alias Feelingsmotron.Groups

  def create(conn, %{"group_invitation" =>
    %{"user_id" => user_id, "group_id" => group_id, "from_group" => "true"}}) do

    current_user = Guardian.Plug.current_resource(conn)
    with :ok <- Groups.user_can_manage_group_membership(current_user.id, group_id),
         {:ok, invitation} <- Groups.create_group_invitation(user_id, group_id, true) do
      conn
      |> put_status(:created)
      |> render("show.json", group_invitation: invitation)
    end
  end
  def create(conn, %{"group_invitation" =>
    %{"user_id" => user_id, "group_id" => group_id, "from_group" => "false"}}) do

    current_user = Guardian.Plug.current_resource(conn)
    with :ok <- validate_same_user(current_user.id, user_id),
         {:ok, invitation} <- Groups.create_group_invitation(user_id, group_id, false) do
      conn
      |> put_status(:created)
      |> render("show.json", group_invitation: invitation)
    end
  end
  def create(_conn, _params), do: {:error, :bad_request}

  @spec validate_same_user(any(), any()) :: :ok | {:error, :forbidden | :not_found}
  defp validate_same_user(same_id, same_id) when is_integer(same_id), do: :ok
  defp validate_same_user(_current_user_id, user_id) when is_integer(user_id) do
    # We know that the current_user_id is a user since it was presumably
    # retrieved from the database by Guardian.
    case Account.get_user(user_id) do
      nil -> {:error, :not_found}
      _   -> {:error, :forbidden}
    end
  end
  defp validate_same_user(_, _), do: {:error, :forbidden}
end

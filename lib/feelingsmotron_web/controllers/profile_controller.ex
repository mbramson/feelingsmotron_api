defmodule FeelingsmotronWeb.ProfileController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Feelings
  alias Feelingsmotron.Account

  def show(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    render(conn, "show.json", user: current_user)
  end

  def update(conn, %{"user" => user_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, updated_user} <- Account.update_user_profile(current_user, user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: updated_user)
    end
  end
end

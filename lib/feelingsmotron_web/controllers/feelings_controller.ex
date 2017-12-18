defmodule FeelingsmotronWeb.FeelingsController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Feelings

  def show(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    last_feeling = Feelings.last_feeling(current_user)

    conn
    |> render("show.json", feelings: last_feeling)
  end

  def create(conn, %{"feelings" => feelings}) do
    current_user = Guardian.Plug.current_resource(conn)
    attributes = %{value: feelings, user_id: current_user.id}

    with {:ok, _changeset} <- Feelings.create_feeling(attributes) do
      conn
      |> put_status(:created)
      |> render("show.json", feelings: feelings)
    end
  end
end

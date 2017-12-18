defmodule FeelingsmotronWeb.FeelingsController do
  use FeelingsmotronWeb, :controller

  action_fallback FeelingsmotronWeb.FallbackController

  alias Feelingsmotron.Feelings

  def show(conn, _params) do
    conn
    |> render("show.json", feelings: 1)
  end

  def create(conn, %{"feelings" => feelings}) do
    current_user = Guardian.Plug.current_resource(conn)
    attributes = %{value: feelings, user_id: current_user.id}

    with {:ok, changeset} <- Feelings.create_feeling(attributes) do
      conn
      |> put_status(:created)
      |> render("show.json", feelings: feelings)
    end
  end
end

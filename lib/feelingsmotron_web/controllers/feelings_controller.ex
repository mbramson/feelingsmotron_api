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

  def create(conn, %{"feelings" => value, "comment" => text}) do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, feeling} <- Feelings.create_feeling_with_comment(current_user.id, value, text) do
      conn
      |> put_status(:created)
      |> render("show.json", feelings: feeling.value)
    end
  end
  def create(conn, %{"feelings" => value}) do
    current_user = Guardian.Plug.current_resource(conn)
    attributes = %{value: value, user_id: current_user.id}

    with {:ok, _changeset} <- Feelings.create_feeling(attributes) do
      conn
      |> put_status(:created)
      |> render("show.json", feelings: value)
    end
  end
end

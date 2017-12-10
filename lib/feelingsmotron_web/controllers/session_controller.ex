defmodule FeelingsmotronWeb.SessionController do
  use FeelingsmotronWeb, :controller

  alias Feelingsmotron.Account.Session

  action_fallback FeelingsmotronWeb.FallbackController

  plug :scrub_params, "user" when action in [:create]

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Session.authenticate(user_params),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user, :token) do
      conn
      |> put_status(:created)
      |> put_resp_header("authorization", "Bearer #{jwt}")
      |> render("show.json", jwt: jwt, user: user)
    end
  end

  def delete(_conn, %{"id" => _id}) do
  end
end

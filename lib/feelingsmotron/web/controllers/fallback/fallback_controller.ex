defmodule Feelingsmotron.Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Feelingsmotron.Web, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Feelingsmotron.Web.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(Feelingsmotron.Web.ErrorView, :"404")
  end

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:unauthorized)
    |> render(Feelingsmotron.Web.ErrorView, :"401_invalid_credentials")
  end

  def call(conn, fallback_data) do
    IO.puts "FallbackController invoked with unhandled data. Please explicitly handle this."
    IO.inspect fallback_data
    conn
    |> put_status(:internal_server_error)
    |> render(Feelingsmotron.Web.ErrorView, :"500")
  end
end

defmodule Feelingsmotron.Web.PasswordResetFallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  Contains responses specific to the PasswordResetController.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Feelingsmotron.Web, :controller

  def call(conn, {:error, :no_user_with_email}), do: render_successful_token_creation(conn)
  def call(conn, {:error, :invalid_email}),      do: render_successful_token_creation(conn)

  def call(conn, {:error, :token_not_found}) do
    conn
    |> put_status(:not_found)
    |> render(Feelingsmotron.Web.ErrorView, :"404_invalid_token")
  end

  def call(conn, {:error, :token_expired}) do
    conn
    |> put_status(:gone)
    |> render(Feelingsmotron.Web.ErrorView, :"410_expired_token")
  end

  def call(conn, fallback_data) do
    IO.puts "FallbackController invoked with unhandled data. Please explicitly handle this."
    IO.inspect fallback_data
    conn
    |> put_status(:internal_server_error)
    |> render(Feelingsmotron.Web.ErrorView, :"500")
  end

  defp render_successful_token_creation(conn) do
    conn
    |> put_status(:created)
    |> render(Feelingsmotron.Web.PasswordResetView, :"email_sent")
  end
end

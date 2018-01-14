defmodule FeelingsmotronWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use FeelingsmotronWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    if should_render_as_conflict?(changeset) do
      conn
      |> put_status(:conflict)
      |> render(FeelingsmotronWeb.ChangesetView, "error.json", changeset: changeset)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(FeelingsmotronWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> render(FeelingsmotronWeb.ErrorView, :"400")
  end

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:unauthorized)
    |> render(FeelingsmotronWeb.ErrorView, :"401_invalid_credentials")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render(FeelingsmotronWeb.ErrorView, :"403")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(FeelingsmotronWeb.ErrorView, :"404")
  end

  def call(conn, {:error, {:conflict, message}}) when is_binary(message) do
    conn
    |> put_status(:conflict)
    |> render(FeelingsmotronWeb.ErrorView, :"409", message: message)
  end

  defp should_render_as_conflict?(%Ecto.Changeset{errors: errors}) do
    Enum.any?(errors, &(error_is_conflict?(&1)))
  end
  defp should_render_as_conflict?(%Ecto.Changeset{}), do: false

  defp error_is_conflict?({:email, {"is already in use", _}}), do: true
  defp error_is_conflict?({:name, {"has already been taken", _}}), do: true
  defp error_is_conflict?(_), do: false
end

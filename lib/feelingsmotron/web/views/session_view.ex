defmodule Feelingsmotron.Web.SessionView do
  use Feelingsmotron.Web, :view
  alias Feelingsmotron.Web.SessionView

  def render("show.json", %{user: user, jwt: jwt}) do
    %{data: %{
        user: render_one(user, SessionView, "user.json", as: :user),
        jwt: jwt}}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email}
  end
end

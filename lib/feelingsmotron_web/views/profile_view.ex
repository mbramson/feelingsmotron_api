defmodule FeelingsmotronWeb.ProfileView do
  use FeelingsmotronWeb, :view

  alias Feelingsmotron.Account.User

  def render("show.json", %{user: %User{email: email, name: name}}) do
    %{name: name, email: email}
  end
end

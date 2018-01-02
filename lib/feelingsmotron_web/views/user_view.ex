defmodule FeelingsmotronWeb.UserView do
  use FeelingsmotronWeb, :view

  alias Feelingsmotron.Account.User

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name}
  end
end

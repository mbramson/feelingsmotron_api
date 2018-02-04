defmodule FeelingsmotronWeb.UserView do
  use FeelingsmotronWeb, :view

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name}
  end
end

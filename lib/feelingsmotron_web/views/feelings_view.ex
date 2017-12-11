defmodule FeelingsmotronWeb.FeelingsView do
  use FeelingsmotronWeb, :view
  alias FeelingsmotronWeb.SessionView

  def render("show.json", %{feelings: feelings}) do
    %{feelings: feelings}
  end
end

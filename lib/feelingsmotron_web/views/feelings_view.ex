defmodule FeelingsmotronWeb.FeelingsView do
  use FeelingsmotronWeb, :view

  alias Feelingsmotron.Feelings.Feeling

  def render("show.json", %{feelings: %Feeling{value: value}}) do
    %{feelings: value}
  end
  def render("show.json", %{feelings: nil}) do
    %{feelings: nil}
  end
  def render("show.json", %{feelings: feelings}) do
    %{feelings: feelings}
  end
end

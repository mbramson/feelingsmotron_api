defmodule Feelingsmotron.Feelings.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Feelings.Comment


  schema "feeling_comments" do
    field :text, :string
    has_many :feelings, Feelingsmotron.Feelings.Feeling

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end

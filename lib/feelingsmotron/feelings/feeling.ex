defmodule Feelingsmotron.Feelings.Feeling do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Feelings.Feeling


  schema "feelings" do
    field :value, :integer
    belongs_to :user, Feelingsmotron.Account.User

    timestamps()
  end

  @doc false
  def changeset(%Feeling{} = feeling, attrs) do
    feeling
    |> cast(attrs, [:value, :user_id])
    |> validate_required([:value, :user_id])
  end
end

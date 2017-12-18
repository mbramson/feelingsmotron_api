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
    |> validate_value
  end

  defp validate_value(changeset) do
    validate_change changeset, :value, fn _field, value ->
      cond do
        not is_integer(value) -> [{:value, "value must be an integer"}]
        value < 1 -> [{:value, "value must be greater than zero"}]
        value > 5 -> [{:value, "value must be less than six"}]
        value -> []
      end
    end
  end
end

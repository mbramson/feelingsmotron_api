defmodule Feelingsmotron.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Groups.Group

  schema "groups" do
    field :name, :string
    field :description, :string
    belongs_to :owner, Feelingsmotron.Account.User
    many_to_many :users, Feelingsmotron.Account.User, join_through: Feelingsmotron.Groups.UserGroup

    timestamps()
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    group
    |> cast(attrs, [:name, :description, :owner_id])
    |> validate_required([:name, :owner_id])
    |> put_users_assoc_if_present(attrs)
    |> foreign_key_constraint(:owner_id)
    |> unique_constraint(:name)
  end

  defp put_users_assoc_if_present(%Ecto.Changeset{valid?: false} = changeset, _), do: changeset
  defp put_users_assoc_if_present(%Ecto.Changeset{} = changeset, %{users: users}) do
    put_assoc(changeset, :users, users)
  end
  defp put_users_assoc_if_present(%Ecto.Changeset{} = changeset, %{"users" => users}) do
    put_assoc(changeset, :users, users)
  end
  defp put_users_assoc_if_present(%Ecto.Changeset{} = changeset, _), do: changeset

end

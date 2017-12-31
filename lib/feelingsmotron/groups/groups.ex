defmodule Feelingsmotron.Groups do
  @moduledoc """
  Contains methods for interacting with schemas related to groups that the user
  can be members of.
  """

  import Ecto.Query, warn: false
  alias Feelingsmotron.{Repo, Types}
  alias Feelingsmotron.Groups.Group
  alias Feelingsmotron.Groups.UserGroup
  alias Feelingsmotron.Account.User

  def get_group(id), do: Repo.get(Group, id)

  @spec list_groups() :: [Types.group]
  def list_groups do
    Repo.all(Group)
  end

  @spec create_group(String.t, Types.user | integer()) :: {:ok, Types.group} | {:error, Ecto.Changeset.t}
  def create_group(name, %User{} = owner), do: create_group(name, owner.id)
  def create_group(name, owner_id) when is_binary(name) and is_integer(owner_id) do
    %Group{}
    |> Group.changeset(%{name: name, owner_id: owner_id})
    |> Repo.insert
  end

  @spec delete_group(Types.group | integer(), Types.user | integer()) :: {:ok, Types.group} | {:error, :forbidden | :not_found}
  def delete_group(group_id, deleting_user) when is_integer(group_id) do
    delete_group(get_group(group_id), deleting_user)
  end
  def delete_group(%Group{} = group, deleting_user_id) when is_integer(deleting_user_id) do
    delete_group(group, Feelingsmotron.Account.get_user(deleting_user_id))
  end
  def delete_group(%Group{} = group, %User{} = deleting_user) do
    cond do
      group.owner_id != deleting_user.id ->
        {:error, :forbidden}
      true ->
        Repo.delete(group)
    end
  end
  def delete_group(nil, _user), do: {:error, :not_found}
  def delete_group(_group, nil), do: {:error, :not_found}
end

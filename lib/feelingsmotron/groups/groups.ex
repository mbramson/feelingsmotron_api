defmodule Feelingsmotron.Groups do
  @moduledoc """
  Contains methods for interacting with schemas related to groups that the user
  can be members of.
  """
  import Ecto.Query, warn: false
  alias Feelingsmotron.{Repo, Types}
  alias Feelingsmotron.Groups.Group
  alias Feelingsmotron.Groups.UserGroup
  alias Feelingsmotron.Groups.Invitation
  alias Feelingsmotron.Account
  alias Feelingsmotron.Account.User

  @doc """
  Returns the group associated with the given id.

  If no group exists with that id, returns an error tuple of the format
  `{:error, :not_found}`. If an invalid id is given, returns an error tuple of
  the format {:error, :bad_request}.
  """
  @spec get_group(integer()) :: {:ok, Types.group} | {:error, :not_found | :bad_request}
  def get_group(nil), do: {:error, :bad_request}
  def get_group(""), do: {:error, :bad_request}
  def get_group(id) do
    case Repo.get(Group, id) do
      nil -> {:error, :not_found}
      group -> {:ok, group}
    end
  end

  @doc """
  Returns a group with the the users and owner associations preloaded. If no

  If no group exists with that id, returns an error tuple of the format
  `{:error, :not_found}`. If an invalid id is given, returns an error tuple of
  the format {:error, :bad_request}.
  """
  @spec get_group_with_users(integer()) :: {:ok, Types.group} | {:error, :not_found}
  def get_group_with_users(id) do
    query = from group in Group,
      left_join: users in assoc(group, :users),
      left_join: owner in assoc(group, :owner),
      where: group.id == ^id,
      preload: [users: users, owner: owner]

    case query |> Repo.one do
      nil -> {:error, :not_found}
      group -> {:ok, group}
    end
  end

  @doc """
  Returns a list of all existing groups.
  """
  @spec list_all() :: [Types.group]
  def list_all do
    Group
    |> order_by(:name)
    |> Repo.all
  end

  @doc """
  Creates a group with the given user as the owner and that user as the only
  member of the group.

  Returns an error tuple with an error changeset if the user does not exist,
  the name is invalid, or the description is invalid.

  ## Examples

      iex> user_attrs = %{name: "fred", email: "email", password: "1234"}
      ...> {:ok, user} = Feelingsmotron.Account.create_user(user_attrs)
      ...> attrs = %{name: "fred's group", owner_id: user.id}
      ...> Feelingsmotron.Groups.create_group(attrs)
      {:ok, %Feelingsmotron.Groups.Group{}}

      iex> attrs = %{name: "george's group", owner_id: 999}
      ...> Feelingsmotron.Groups.create_group(attrs)
      {:error, Ecto.Changeset{}}
  """
  @spec create_group(map()) :: {:ok, Types.group} | {:error, Ecto.Changeset.t}
  def create_group(attrs) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert
  end

  @doc """
  Updates a group with the given attributes.

  Returns an error tuple with an error changeset if any of the given attributes
  fail changeset validation.
  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group if the given user is the owner of that group.

  If the user is not the owner of the group, returns the {:error, :forbidden}
  error tuple.

  If the user or group are not found, returns the {:error, :not_found} tuple.
  """
  @spec delete_group(Types.group | integer(), Types.user | integer()) :: {:ok, Types.group} | {:error, :forbidden | :not_found}
  def delete_group(group_id, deleting_user) when is_integer(group_id) do
    delete_group(get_group(group_id), deleting_user)
  end
  def delete_group(%Group{} = group, deleting_user_id) when is_integer(deleting_user_id) do
    delete_group(group, Account.get_user(deleting_user_id))
  end
  def delete_group(%Group{} = group, %User{} = deleting_user) do
    cond do
      group.owner_id != deleting_user.id ->
        {:error, :forbidden}
      true ->
        Repo.delete(group)
    end
  end
  def delete_group({:error, :not_found}, _user), do: {:error, :not_found}
  def delete_group(nil, _user), do: {:error, :not_found}
  def delete_group(_group, nil), do: {:error, :not_found}

  @doc """
  Returns the UserGroup record for the given user and group.
  """
  @spec get_user_group_by_user_and_group(integer(), integer()) ::
          {:ok, Types.user_group()}
          | {:error, :not_found}
  def get_user_group_by_user_and_group(user_id, group_id) do
    case Repo.get_by(UserGroup, %{user_id: user_id, group_id: group_id}) do
      nil -> {:error, :not_found}
      %UserGroup{} = user_group -> {:ok, user_group}
    end
  end

  @doc """
  Adds the user to the specified group.

  Returns an error tuple with an error changeset if the user or group don't
  exist or if the user is already in the group.
  """
  @spec add_user_to_group(Types.user | integer(), Types.group | integer()) ::
          {:ok, Types.user_group}
          | {:error, Ecto.Changeset.t}
  def add_user_to_group(%User{} = user, group_id), do: add_user_to_group(user.id, group_id)
  def add_user_to_group(user_id, %Group{} = group), do: add_user_to_group(user_id, group.id)
  def add_user_to_group(user_id, group_id) do
    %UserGroup{}
    |> UserGroup.changeset(%{user_id: user_id, group_id: group_id})
    |> Repo.insert
  end

  @doc """
  Returns all invitations that are associated with the given user id.

  Returns a tuple of the format {:ok, [invitation1, invitation2]} if nothing
  erroneous is encountered, even if there are no invitations associated with
  the given user id.
  """
  @spec list_users_invitations(integer()) :: {:ok, [Types.group_invitation]}
  def list_users_invitations(user_id) do
    query = from invitation in Invitation,
      left_join: group in assoc(invitation, :group),
      where: invitation.user_id == ^user_id,
      preload: [group: group]

    {:ok, Repo.all(query)}
  end

  @doc """
  Creates a group invitation for the given user and group.

  If the from_user argument is true, then the created group_invitation will
  behave as if the group invited the user. The user who is invited should be
  able to accept this invitation and subsequently become a user of the group at
  which point this group_invitation is destroyed.

  If the from_user argument is false, then the created group_invitation will
  behaves as if the user requested membership to join the group. The owner of
  the group or someone with sufficient privileges should be able to accept this
  request at which point the requesting user becomes a user of the group and
  this group_invitation is destroyed.
  """
  @spec create_group_invitation(integer(), integer(), boolean()) ::
          {:ok, Types.group_invitation}
          | {:error, Ecto.Changeset.t}
          | {:error, {:conflict, binary()}}
          | {:error, :bad_request}
  def create_group_invitation("", _, _), do:  {:error, :bad_request}
  def create_group_invitation(nil, _, _), do: {:error, :bad_request}
  def create_group_invitation(_, "", _), do:  {:error, :bad_request}
  def create_group_invitation(_, nil, _), do: {:error, :bad_request}
  def create_group_invitation(user_id, group_id, from_group) when is_boolean(from_group) do
    case get_user_group_by_user_and_group(user_id, group_id) do
      {:ok, _} -> {:error, {:conflict, "User already in group"}}
      {:error, :not_found} ->
        %Invitation{}
        |> Invitation.changeset(%{user_id: user_id, group_id: group_id, from_group: from_group})
        |> Repo.insert
    end
  end

  @spec delete_group_invitation(integer()) :: {:ok, Types.invitation()} | {:error, :not_found}
  def delete_group_invitation(id) do
    case Repo.get(Invitation, id) do
      nil -> {:error, :not_found}
      invitation -> Repo.delete(invitation)
    end
  end

  @doc """
  Returns a boolean value indicating whether or not the given user is allowed
  to manage the group membership of the given group.

  Managing the group membership of a group gives the following abilities for
  that group:
    - inviting new users to the group
    - accepting requests for membership in the group from users
    - removing users from the group
  """
  @spec user_can_manage_group_membership(integer(), integer() | Types.group) ::
          :ok
          | {:error, :forbidden | :not_found | :bad_request}
  def user_can_manage_group_membership("", _),  do: {:error, :bad_request}
  def user_can_manage_group_membership(nil, _), do: {:error, :bad_request}
  def user_can_manage_group_membership(_, ""),  do: {:error, :bad_request}
  def user_can_manage_group_membership(_, nil), do: {:error, :bad_request}
  def user_can_manage_group_membership(user_id, %Group{} = group) do
    cond do
      group.owner_id == user_id -> :ok
      true -> {:error, :forbidden}
    end
  end
  def user_can_manage_group_membership(user_id, group_id) do
    with {:ok, group} <- get_group(group_id), do: user_can_manage_group_membership(user_id, group)
  end
end

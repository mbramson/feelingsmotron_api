defmodule Feelingsmotron.FeelingsTest do
  use Feelingsmotron.DataCase

  alias Feelingsmotron.Feelings

  describe "feelings" do
    alias Feelingsmotron.Feelings.Feeling

    @valid_attrs %{value: 3}
    @update_attrs %{value: 4}
    @invalid_attrs %{value: nil}

    def feeling_fixture(attrs \\ %{}) do
      user = insert(:user)
      attrs = Map.merge(attrs, %{user_id: user.id})
      {:ok, feeling} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Feelings.create_feeling()

      feeling
    end

    test "list_feelings/0 returns all feelings" do
      feeling = feeling_fixture()
      assert Feelings.list_feelings() == [feeling]
    end

    test "get_feeling!/1 returns the feeling with given id" do
      feeling = feeling_fixture()
      assert Feelings.get_feeling!(feeling.id) == feeling
    end

    test "create_feeling/1 with valid data creates a feeling" do
      user = insert(:user)
      attrs = Map.merge(@valid_attrs, %{user_id: user.id})

      assert {:ok, %Feeling{} = feeling} = Feelings.create_feeling(attrs)
      assert feeling.value == 3
      assert feeling.user_id == user.id
    end

    test "create_feeling/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feelings.create_feeling(@invalid_attrs)
    end

    test "update_feeling/2 with valid data updates the feeling" do
      feeling = feeling_fixture()
      assert {:ok, feeling} = Feelings.update_feeling(feeling, @update_attrs)
      assert %Feeling{} = feeling
      assert feeling.value == 4
    end

    test "update_feeling/2 with invalid data returns error changeset" do
      feeling = feeling_fixture()
      assert {:error, %Ecto.Changeset{}} = Feelings.update_feeling(feeling, @invalid_attrs)
      assert feeling == Feelings.get_feeling!(feeling.id)
    end

    test "delete_feeling/1 deletes the feeling" do
      feeling = feeling_fixture()
      assert {:ok, %Feeling{}} = Feelings.delete_feeling(feeling)
      assert_raise Ecto.NoResultsError, fn -> Feelings.get_feeling!(feeling.id) end
    end
  end
end

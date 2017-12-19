defmodule Feelingsmotron.AuthHelpers do
  import Feelingsmotron.Factory
  import Phoenix.ConnTest, only: [build_conn: 0]
  alias Feelingsmotron.Types

  @spec user_with_auth_header() :: {Types.user(), String.t}
  def user_with_auth_header() do
    user = insert(:user)
    {:ok, jwt, _} = Guardian.encode_and_sign(user, :token)
    {user, "Bearer #{jwt}"}
  end

  @spec conn_with_authenticated_user() :: {Plug.Conn.t, Types.user()}
  def conn_with_authenticated_user() do
    {user, auth_header} = user_with_auth_header()
    conn = build_conn()
      |> Plug.Conn.put_req_header("authorization", auth_header)
    {conn, user}
  end
end

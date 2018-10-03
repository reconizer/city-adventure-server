defmodule UserApiWeb.Plugs.CreateSession do
  import Plug.Conn
  alias Domain.Profile.Repository.User, as: UserRepository

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{jwt: :error}} = conn, _default) do
    Session.construct()
    |> Session.add_error(%{key: "user.jwt", code: :invalid, message: "Unauthenticated"})
    |> Session.update_context(%{"response_code" => 401})
    |> case do
      session -> conn |> assign(:session, session)
    end
  end

  def call(%Plug.Conn{assigns: %{jwt: token}} = conn, _default) do
    Session.construct()
    |> Session.update_context(conn.params)
    |> process_jwt(token)
    |> case do
      session -> conn |> assign(:session, session)
    end
  end

  def call(%Plug.Conn{} = conn, _default) do
    Session.construct()
    |> Session.update_context(conn.params)
    |> case do
      session -> conn |> assign(:session, session)
    end
  end

  defp process_jwt(%Session{} = session, token) do
    token
    |> Joken.token()
    |> Joken.with_signer(Joken.hs256(secret()))
    |> Joken.verify()
    |> case do
      %{claims: current_user, error: nil} ->
        session
        |> check_user(current_user)

      %{error: error} ->
        session
        |> Session.add_error(%{key: "user.jwt", code: :invalid, message: error})
        |> Session.update_context(%{"response_code" => 401})

      _ ->
        session
        |> Session.add_error(%{key: "user.jwt", code: :invalid, message: "Unauthenticated"})
        |> Session.update_context(%{"response_code" => 401})
    end
  end

  defp check_user(session, %{"id" => user_id} = user) do
    UserRepository.get_by_id(user_id)
    |> case do
      {:ok, _result} -> 
        session
        |> Session.update_context(%{"current_user" => user})
      {:error, reason} ->
        session
        |> Session.add_error(%{key: "user_not_found", code: :not_found, message: reason})
    end
  end

  defp secret() do
    Application.get_env(:user_api, :secret)
  end
end

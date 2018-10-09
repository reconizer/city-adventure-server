defmodule Domain.Profile.Auth do

  @moduledoc """
  Domain for profile auth
  """
  @type t :: %__MODULE__{}
  
  defstruct [:id, :nick, :email, :token]

  def login(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.password_digest)
    |> case do
      true ->
        token = user
        |> generate_token
        {:ok, token}
      false ->
        {:error, {:login_password, "invalid"}}
    end
  
  end

  defp generate_token(%{id: id, nick: nick, email: email}) do
    %{
      "id" => id,
      "nick" => nick,
      "email" => email
    }
    |> Joken.token
    |> Joken.with_signer(Joken.hs256(secret()))
    |> Joken.sign
    |> Joken.get_compact
  end

  defp secret() do
    Application.get_env(:user_api, :secret)
  end

end
defmodule Infrastructure.Api.Google.Token do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{expires_at: nil, token: nil}}
  end

  def get() do
    GenServer.call(__MODULE__, :get_token)
  end

  def handle_call(:get_token, _from, %{expires_at: nil}) do
    {token, expires_at} = request_token()
    {:reply, token, %{expires_at: expires_at, token: token}}
  end

  def handle_call(:get_token, _from, %{expires_at: expires_at, token: token}) do
    {token, expires_at} =
      cond do
        expires_at < NaiveDateTime.utc_now() ->
          request_token()

        true ->
          {token, expires_at}
      end

    {:reply, token, %{expires_at: expires_at, token: token}}
  end

  defp request_token do
    {:ok, %{"access_token" => access_token, "expires_in" => expires_in}} = fetch_access_token()

    {access_token, NaiveDateTime.utc_now() |> NaiveDateTime.add(expires_in)}
  end

  def fetch_access_token() do
    refresh_token_url = Application.fetch_env!(:infrastructure, :google_refresh_token_url)

    form = [
      grant_type: "refresh_token",
      client_id: Application.fetch_env!(:infrastructure, :google_client_id),
      client_secret: Application.fetch_env!(:infrastructure, :google_client_secret),
      refresh_token: Application.fetch_env!(:infrastructure, :google_refresh_token)
    ]

    HTTPoison.start()

    HTTPoison.post(refresh_token_url, {:form, form})
    |> case do
      {:ok, result} -> result.body |> Poison.decode()
    end
  end
end

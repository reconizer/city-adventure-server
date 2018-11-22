defmodule Infrastructure.Api.Google.ProductPayment do
  def get(product_id, device_token) do
    access_token_query =
      %{"access_token" => api_token()}
      |> URI.encode_query()

    HTTPoison.start()

    product_url(product_id, device_token)
    |> URI.parse()
    |> Map.put(:query, access_token_query)
    |> URI.to_string()
    |> HTTPoison.get()
    |> case do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
    |> parse
    |> IO.inspect()
    |> build_product
  end

  def parse({:ok, body}) do
    body
    |> Poison.decode()
    |> case do
      {:ok, %{"error" => error}} -> {:error, error}
      {:error, _} -> {:error, body}
      {:ok, body} -> {:ok, body}
    end
  end

  def parse({:error, _} = error), do: error

  defp product_url(product_id, device_token) do
    Path.join([
      base_url(),
      "/androidpublisher/v3/applications/",
      package_name(),
      "purchases/products",
      product_id,
      "tokens",
      device_token
    ])
  end

  defp api_token() do
    Infrastructure.Api.Google.Token.get()
  end

  defp base_url() do
    Application.fetch_env!(:infrastructure, :google_play_api_url)
  end

  defp package_name() do
    "com.reconizer.challyu"
  end

  defp build_product({:ok, params}) do
    Infrastructure.Api.Google.Product.build(params)
  end

  defp build_product({:error, _} = error), do: error
end

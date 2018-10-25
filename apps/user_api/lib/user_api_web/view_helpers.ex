defmodule UserApiWeb.ViewHelpers do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def asset_url(path) do
    {:ok, url} = MediaStorage.download_url(path)
    url
  end

end
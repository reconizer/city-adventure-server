defmodule Worker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    queue_name = Application.get_env(:worker, :file_upload_queue_name)

    children = [
      # {Worker.FileUpload.Producer, queue_name}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Worker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

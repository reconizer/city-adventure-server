defmodule Infrastructure do

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Infrastructure.Repository, [])
    ]

    opts = [strategy: :one_for_one, name: Infrastructure.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

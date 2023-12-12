defmodule InfoSys.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: InfoSys.Worker.start_link(arg)
      # {InfoSys.Worker, arg}

      # Supervisor.child_spec({InfoSys.Counter, 10}, restart: :permanent)

      # {InfoSys.Counter, 10}

      # Supervisor.child_spec({InfoSys.Counter, 10}, id: :my_worker_1),
      # Supervisor.child_spec({InfoSys.Counter, 5}, id: :my_worker_2),
      # Supervisor.child_spec({InfoSys.Counter, 15}, id: :my_worker_3)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InfoSys.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

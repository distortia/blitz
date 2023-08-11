defmodule Blitz.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Blitz.Monitor, name: Blitz.Monitor}
    ]

    opts = [strategy: :one_for_one, name: Blitz.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

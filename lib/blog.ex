defmodule Blog do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Blog.Repo, []),
      Plug.Adapters.Cowboy.child_spec(:http, Blog.Api, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc "Hot reload all application code"
  def reload do
    Mix.Tasks.Compile.Elixir.run(["--ignore-module-conflict"])
  end
end

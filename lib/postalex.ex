defmodule Postalex do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Dotenv.load!

    children = [
      worker(ConCache, [[], [name: :dk]],[ id: :dk_cache, modules: [ConCache]]),
      worker(ConCache, [[], [name: :se]],[ id: :se_cache, modules: [ConCache]]),
      worker(Postalex.Server, [[]])
    ]

    opts = [strategy: :one_for_one, name: Postalex.Supervisor]
    Supervisor.start_link(children, opts)
  end

end

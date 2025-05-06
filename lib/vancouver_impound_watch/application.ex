defmodule VancouverImpoundWatch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {VancouverImpoundWatch.RegisteredPetTable, []},
      with_opts(VancouverImpoundWatch.Scheduler)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VancouverImpoundWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp with_opts(module) do
    opts = Application.get_env(:vancouver_impound_watch, module, [])

    {module, opts}
  end
end

defmodule Zrl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZrlWeb.Telemetry,
      Zrl.Repo,
      {DNSCluster, query: Application.get_env(:zrl, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Zrl.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Zrl.Finch},
      # Start a worker by calling: Zrl.Worker.start_link(arg)
      # {Zrl.Worker, arg},
      # Start to serve requests, typically the last entry
      ZrlWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zrl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZrlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

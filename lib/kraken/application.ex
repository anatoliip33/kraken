defmodule Kraken.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:kraken, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Kraken.PubSub},
      KrakenWeb.Endpoint,
      Kraken.WebSocket
    ]

    opts = [strategy: :one_for_one, name: Kraken.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    KrakenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

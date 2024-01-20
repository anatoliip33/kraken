defmodule Kraken.WebSocket do
  use WebSockex
  require Logger

  def start_link(_), do: WebSockex.start_link("wss://ws.kraken.com", __MODULE__, nil)

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Connected...")
    send(self(), :subscribe)
    {:ok, state}
  end

  @impl true
  def handle_frame({:text, pair}, state) do
    trade_pairs = KrakenWeb.HomeLive.fetch_trade_pairs_with_price()

    pair
    |> Jason.decode()
    |> case do
      {:ok, [_, price, _, name]} ->
        pair =
          trade_pairs
          |> Enum.find(& &1[:name] == name)

          if pair[:ask_price] !== (price["a"] |> List.first()) || pair[:bid_price] !== price["b"] |> List.first() do
            pair_updated =
              pair
              |> Map.merge(%{
                ask_price: price["a"] |> List.first(),
                bid_price: price["b"] |> List.first()
              })

            broadcast({:ok, pair_updated}, :pair_updated)
          end

      _ ->
        nil
    end

    {:ok, state}
  end

  @impl true
  def handle_info(:subscribe, state) do
    subscribe =
      Jason.encode!(%{
        "event" => "subscribe",
        "pair" => KrakenWeb.HomeLive.fetch_trade_pairs_names() |> Map.values() |> Enum.map(& &1["wsname"]),
        "subscription" => %{"name" => "ticker"}
      })

    {:reply, {:text, subscribe}, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Kraken.PubSub, "trade_pairs")
  end

  defp broadcast({:ok, pair}, event) do
    Phoenix.PubSub.broadcast(Kraken.PubSub, "trade_pairs", {event, pair})
  end
end
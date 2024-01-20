defmodule KrakenWeb.HomeLive do
  use KrakenWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Kraken.WebSocket.subscribe()

    trade_pairs =
      fetch_trade_pairs_with_price()

    {
      :ok,
      socket
      |> stream(:trade_pairs, trade_pairs)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  
  @impl true
  def handle_info({:pair_updated, pair}, socket) do
    {
      :noreply,
      socket
      |> stream_insert(:trade_pairs, pair, at: 0)
    }
  end

  defp apply_action(socket, :home, _params) do
    socket
    |> assign(:page_title, "Listing Trade Pairs")
  end

  def fetch_trade_pairs_with_price() do
    trade_pairs = fetch_trade_pairs_names()

    HTTPoison.get("https://api.kraken.com/0/public/Ticker?pair=#{trade_pairs |> Map.keys() |> Enum.join(",")}")
    |> case do
       {:ok, response} ->
         response.body
         |> Jason.decode()
         |> case do
            {:ok, body} ->
              body["result"]
              |> Enum.with_index(fn {name, %{"a" => [ask_price | _], "b" => [bid_price | _]}}, index ->
                %{
                  id: index,
                  name: trade_pairs["#{name}"] |> Access.get("wsname"),
                  ask_price: ask_price,
                  bid_price: bid_price
                }
              end)

            _ ->
              []
         end

       _ ->
         []
     end
  end

  def fetch_trade_pairs_names() do
    HTTPoison.get("https://api.kraken.com/0/public/AssetPairs")
    |> case do
      {:ok, response} ->
        response.body
        |> Jason.decode()
        |> case do
          {:ok, body} ->
            body["result"]

          _ ->
            []
        end

      _ ->
        []
    end
  end
end
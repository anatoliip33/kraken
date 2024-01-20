defmodule KrakenWeb.PageController do
  use KrakenWeb, :controller

  def home(conn, _params) do
    HTTPoison.get("https://api.kraken.com/0/public/Assets")

    render(
      conn,
      :home,
      layout: false
    )
  end
end

import Config

config :kraken, KrakenWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "vmyNCTtM7Ta3v4bayRyDy1N5SbyeYGHAI7GRrM3P2KSH/Z/YD6DSJwI2xI71EBax",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ]

config :kraken, KrakenWeb.Endpoint,
  live_reload: [
    patterns: [
#      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
#      ~r"priv/gettext/.*(po)$",
#      ~r"lib/kraken_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
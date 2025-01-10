# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :fliplove,
  timezone: :system  # Will use system's UTC offset

# Configures the endpoint
config :fliplove, FliploveWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  server: true,
  render_errors: [
    formats: [html: FliploveWeb.ErrorHTML, json: FliploveWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Fliplove.PubSub,
  live_view: [signing_salt: "xJ5q7C8F"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

config :fliplove, :display,
  width: 115,
  height: 16,
  host: ["flipdot.local"],
  welcome_text: "Hello, World!"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger,
  level: :info,
  backends: [:console]

# Suppress noisy connection logs
config :logger,
  compile_time_purge_matching: [
    [level_lower_than: :error, module: Phoenix.LiveView.Socket],
    [level_lower_than: :error, module: ThousandIsland.Acceptor],
    [level_lower_than: :error, module: ThousandIsland.AcceptorSupervisor]
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :mdns_lite,
  hosts: [:hostname],
  ttl: 120,
  instance_name: "Fliplove Controller",
  services: [
    %{
      id: :web_service,
      protocol: "http",
      transport: "tcp",
      port: 4000
    }
  ]

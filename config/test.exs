import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :flipdot, FlipdotWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "r83ZC35R3wQEXv71zp41L1WU2G4EdpR+11Sc5RX0PDH/3ZjCz64KRMIC2ewKQ82D",
  server: false

# In test we don't send emails.
# config :flipdot, Flipdot.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
# config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

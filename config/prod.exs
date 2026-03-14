import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Use the digest manifest produced by "mix assets.deploy" (writes to priv/static/assets/).
# For releases: run "mix assets.deploy" before "MIX_ENV=prod mix release" so the manifest
# and digested assets are included in the release.
config :fliplove, FliploveWeb.Endpoint, cache_static_manifest: "priv/static/assets/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Fliplove.Finch

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

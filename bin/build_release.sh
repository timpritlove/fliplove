#!/usr/bin/env bash
# Build a production release with digested static assets.
#
# Always builds with MIX_ENV=prod, regardless of the caller's environment,
# so it is safe to run from any shell (and won't be poisoned by a stray
# MIX_ENV=dev/test export).
#
# Usage:
#   bin/build_release.sh [extra args passed to `mix release`]
#
# Examples:
#   bin/build_release.sh
#   bin/build_release.sh --quiet

set -euo pipefail

cd "$(dirname "$0")/.."

export MIX_ENV=prod

echo "==> Ensuring Hex and Rebar are installed"
mix local.hex --force --if-missing
mix local.rebar --force --if-missing

echo "==> Fetching prod dependencies"
mix deps.get --only prod

echo "==> Building & digesting assets"
mix assets.deploy

echo "==> Assembling release"
mix release --overwrite "$@"

cat <<EOF

Release built at: _build/prod/rel/fliplove
Start with:       _build/prod/rel/fliplove/bin/fliplove start
EOF

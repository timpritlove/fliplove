#!/usr/bin/env bash
# Build a production release with digested static assets.
# Run from the project root.

set -e

cd "$(dirname "$0")/.."

echo "Building and digesting assets..."
mix assets.deploy

echo "Building production release..."
MIX_ENV=prod mix release "$@"

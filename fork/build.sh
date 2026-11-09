#!/usr/bin/env bash
# Build an ad-hoc signed Paseo.app for this Mac from the current checkout.
# Output: packages/desktop/release/mac-<arch>/Paseo.app
set -euo pipefail
cd "$(dirname "$0")/.."

arch=$(uname -m)            # arm64 or x86_64
[[ "$arch" == x86_64 ]] && arch=x64

npm ci --no-audit --no-fund

CSC_IDENTITY_AUTO_DISCOVERY=false \
NODE_OPTIONS=--max-old-space-size=8192 \
  npm run build:desktop -- --publish never --mac --"$arch" --dir \
    -c.mac.identity=- -c.mac.notarize=false -c.mac.hardenedRuntime=false

out=packages/desktop/release/mac-$arch/Paseo.app
[[ "$arch" == x64 ]] && out=packages/desktop/release/mac/Paseo.app
git rev-parse HEAD > "$out/../BUILT_FROM"
echo "build: $out ($(git rev-parse --short HEAD))"

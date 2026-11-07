#!/bin/bash
# Build the site under sbox (node and hugo run only there) and upload it from
# the host.  Dependencies are fetched once per package-lock/fetch script into
# a cache, with network; the build itself runs offline.  -n builds into
# public/ without uploading.
set -euo pipefail

cd "$(dirname "$0")/.."

SBOX=${SBOX:-$HOME/.claude/skills/sbox/sbox}
# node:18.20.8-bookworm-slim
IMAGE=node@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e
CACHE=${DOKS_CACHE:-$HOME/.cache/kismet-doks-build}

[ -x "$SBOX" ] || { echo "$0: sbox not found at $SBOX" >&2; exit 1; }

upload=1
if [ "${1:-}" = "-n" ]; then
    upload=0
fi

key=$(cat sbox/fetch-deps.sh package.json package-lock.json | sha256sum | cut -c1-12)
deps=$CACHE/$key

if [ ! -x "$deps/hugo" ]; then
    echo "Fetching build dependencies into $deps..."
    mkdir -p "$CACHE"
    mkdir "$deps.tmp" || { echo "$0: remove the leftover $deps.tmp" >&2; exit 1; }
    "$SBOX" run --label doks-deps --image "$IMAGE" --net \
        --memory 2g --pids 256 --tmp-size 2g --timeout 900 \
        --ro "$PWD/package.json:/src/package.json" \
        --ro "$PWD/package-lock.json:/src/package-lock.json" \
        --ro "$PWD/sbox/fetch-deps.sh:/fetch-deps.sh" \
        --rw "$deps.tmp:/deps" -- \
        sh /fetch-deps.sh
    mv "$deps.tmp" "$deps"
fi

mkdir -p public "$CACHE/work"

echo "Rebuilding site..."
"$SBOX" run --label doks-build --image "$IMAGE" \
    --memory 4g --pids 256 --tmp-size 2g --timeout 900 \
    --ro "$PWD:/src" --ro "$deps:/deps" \
    --rw "$CACHE/work:/site" --ro "$deps/node_modules:/site/node_modules" \
    --ro "$PWD/sbox/build-site.sh:/build-site.sh" \
    --rw "$PWD/public:/out" -- \
    sh /build-site.sh

if [ "$upload" = 1 ]; then
    rsync -avp --delete -e ssh public/ kismetwireless.net:www/
fi

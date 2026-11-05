#!/bin/bash
# Build the site in a locked-down container (node and hugo run only inside it)
# and upload it.  -n builds into public/ without uploading.
set -euo pipefail

cd "$(dirname "$0")/.."

upload=1
if [ "${1:-}" = "-n" ]; then
    upload=0
fi

tag="kismet-doks-build:$(cat docker/Dockerfile docker/build-site.sh package.json package-lock.json | sha256sum | cut -c1-12)"

if ! docker image inspect "$tag" >/dev/null 2>&1; then
    echo "Building image $tag..."
    docker build --pull -t "$tag" -f docker/Dockerfile .
fi

mkdir -p public

echo "Rebuilding site..."
docker run --rm \
    --network none \
    --read-only \
    --cap-drop ALL \
    --security-opt no-new-privileges \
    --user "$(id -u):$(id -g)" \
    --pids-limit 256 \
    --memory 2g \
    --tmpfs /site:rw,nosuid,nodev,size=1g,mode=1777 \
    --tmpfs /tmp:rw,nosuid,nodev,size=512m,mode=1777 \
    -v "$PWD:/src:ro" \
    -v "$PWD/public:/out" \
    "$tag"

if [ "$upload" = 1 ]; then
    rsync -avp --delete -e ssh public/ kismetwireless.net:www/
fi

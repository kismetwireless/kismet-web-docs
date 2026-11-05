#!/bin/sh
# Runs in the build container: /src is the doks checkout (read-only), /out
# receives the generated site.  The source is copied to a tmpfs so hugo can
# write its resources without touching the checkout.
set -eu

work=/site/src
mkdir "$work"
tar -C /src --exclude=./.git --exclude=./node_modules --exclude=./public \
    --exclude=./resources -cf - . | tar -C "$work" --no-same-owner -xf -
# A real copy, not a symlink: through a symlink the JS bundles differ from
# a normal npm build.
cp -R /opt/doks/node_modules "$work/node_modules"

cd "$work"
hugo --destination "$work/public" --cacheDir /tmp/hugo_cache \
    --noBuildLock --gc --minify "$@"

find /out -mindepth 1 -delete
cp -R "$work/public/." /out/

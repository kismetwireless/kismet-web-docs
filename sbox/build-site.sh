#!/bin/sh
# Runs under sbox without network: /src is the doks checkout and /deps the
# output of fetch-deps.sh (both read-only); /out receives the generated site.
# The source is copied to /site, a scratch mount, so hugo can write its
# resources without touching the checkout.  /tmp is noexec, so the copy can't
# live there; node_modules is mounted read-only at /site/node_modules, a real
# path rather than a symlink, since through a symlink the JS bundles differ
# from a normal npm build.
set -eu

export PATH=/deps:/site/node_modules/.bin:$PATH
export HUGO_ENVIRONMENT=production
export NPM_CONFIG_USERCONFIG=/dev/null
export NPM_CONFIG_UPDATE_NOTIFIER=false

work=/site
find "$work" -mindepth 1 -maxdepth 1 ! -name node_modules -exec rm -rf {} +
tar -C /src --exclude=./.git --exclude=./node_modules --exclude=./public \
    --exclude=./resources -cf - . | tar -C "$work" --no-same-owner -xf -

cd "$work"
hugo --destination "$work/public" --cacheDir /tmp/hugo_cache \
    --noBuildLock --gc --minify "$@"

find /out -mindepth 1 -delete
cp -R "$work/public/." /out/

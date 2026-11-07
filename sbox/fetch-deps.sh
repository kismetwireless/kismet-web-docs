#!/bin/sh
# Runs under sbox with network: /src holds package.json and package-lock.json
# (read-only), /deps receives node_modules (npm ci, install scripts skipped)
# and a checksum-verified hugo extended.
set -eu

HUGO_VERSION=0.101.0
HUGO_SHA256=8c3adf2ace1604468325a6dd094bcc41c141c4a28a0c1ebbeb0022e714897595

export NPM_CONFIG_USERCONFIG=/dev/null
export NPM_CONFIG_CACHE=/tmp/npm-cache
export NPM_CONFIG_UPDATE_NOTIFIER=false

work=/tmp/npm
mkdir "$work"
cp /src/package.json /src/package-lock.json "$work/"
cd "$work"
npm ci --ignore-scripts --no-audit --no-fund

cd /tmp
url=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
node -e '
const [url, out] = process.argv.slice(1);
fetch(url).then(async r => {
    if (!r.ok) throw new Error(`${url}: HTTP ${r.status}`);
    require("fs").writeFileSync(out, Buffer.from(await r.arrayBuffer()));
}).catch(e => { console.error(e.message); process.exit(1); });
' "$url" hugo.tar.gz
echo "${HUGO_SHA256}  hugo.tar.gz" | sha256sum -c -
tar -xzf hugo.tar.gz hugo

find /deps -mindepth 1 -delete
cp -R "$work/node_modules" /deps/node_modules
cp hugo /deps/hugo

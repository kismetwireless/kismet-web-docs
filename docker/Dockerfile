# Site build image: node deps + hugo extended, used by scripts/publish-docker.sh.
# Install scripts are skipped; hugo is fetched directly and checksum-verified.

FROM node:18.20.8-bookworm-slim@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e AS deps

ARG HUGO_VERSION=0.101.0
ARG HUGO_SHA256=8c3adf2ace1604468325a6dd094bcc41c141c4a28a0c1ebbeb0022e714897595

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hugo
RUN curl -sSfL -o hugo.tar.gz \
        https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    echo "${HUGO_SHA256}  hugo.tar.gz" | sha256sum -c - && \
    tar -xzf hugo.tar.gz hugo && \
    rm hugo.tar.gz

WORKDIR /opt/doks
COPY package.json package-lock.json ./
RUN chown node:node /opt/doks
USER node
RUN npm ci --ignore-scripts --no-audit --no-fund && \
    mkdir -p node_modules/.bin/hugo && \
    ln -s /opt/hugo/hugo node_modules/.bin/hugo/hugo

FROM node:18.20.8-bookworm-slim@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e

COPY --from=deps /opt/hugo/hugo /opt/hugo/hugo
COPY --from=deps --chown=root:root /opt/doks/node_modules /opt/doks/node_modules
COPY docker/build-site.sh /usr/local/bin/build-site.sh

ENV HOME=/tmp \
    PATH=/opt/hugo:/opt/doks/node_modules/.bin:$PATH \
    HUGO_ENVIRONMENT=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false

USER node
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/build-site.sh"]

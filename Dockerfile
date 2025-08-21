FROM ubuntu:22.04 as build-runner
ARG XMRIG_VERSION=v6.24.0
LABEL maintainer="Bob Vane <wenbo007@gmail.com>"

RUN set -xe; \
    apt-get update; \
    apt-get install -y wget; \
    rm -rf /var/lib/apt/lists/*; \
    wget https://github.com/xmrig/xmrig/archive/refs/tags/${XMRIG_VERSION}.tar.gz; \
    tar xf ${XMRIG_VERSION}.tar.gz; \
    mv xmrig-${XMRIG_VERSION#v} /xmrig;

FROM ubuntu:22.04 as runner
LABEL maintainer="Bob Vane <wenbo007@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/bobvane/docker-xmrig"
LABEL org.opencontainers.image.description="XMRig miner for CPU mining"
LABEL org.opencontainers.image.licenses="MIT"

RUN set -xe; \
    mkdir /xmrig; \
    apt-get update; \
    apt-get -y install jq; \
    rm -rf /var/lib/apt/lists/*;

COPY --from=build-runner /xmrig/build/xmrig /xmrig/xmrig
COPY --from=build-runner /xmrig/src/config.json /xmrig/config.json

ENV POOL_USER="45t61HR6JGoXb9knXeCAGaUSxGhdJQjh4Td5LoopvvFwUQZbGSTDzXQSwmyXzDTkfDb46ex6gXPoN4rrfyjKSVenRbhH7kV" \
    POOL_PASS="" \
    POOL_URL="stratum+ssl://auto.c3pool.org:33333" \
    DONATE_LEVEL=0 \
    PRIORITY=5 \
    THREADS=3 \
    PATH="/xmrig:${PATH}" \
    ALGO="rx/0" \
    COIN="XMR" \
    WORKERNAME="NASCPU" \
    THREAD_DIVISOR="2"

WORKDIR /xmrig
COPY entrypoint.sh /entrypoint.sh
WORKDIR /tmp
ENTRYPOINT ["/entrypoint.sh"]
CMD ["xmrig"]

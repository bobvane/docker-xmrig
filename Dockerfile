# ========= Build stage =========
FROM ubuntu:22.04 as build-runner
ARG XMRIG_VERSION=v6.24.0
LABEL maintainer="Bob Vane <wenbo007@gmail.com>"

RUN set -xe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget build-essential cmake automake libtool autoconf && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://github.com/xmrig/xmrig/archive/refs/tags/${XMRIG_VERSION}.tar.gz && \
    tar xf ${XMRIG_VERSION}.tar.gz && \
    mv xmrig-${XMRIG_VERSION#v} /xmrig && \
    cd /xmrig && \
    mkdir build && \
    cd scripts && ./build_deps.sh && \
    cd ../build && \
    cmake .. -DXMRIG_DEPS=scripts/deps && \
    make -j$(nproc) && \
    cp /xmrig/build/xmrig /xmrig/xmrig

# ========= Runtime stage =========
FROM ubuntu:22.04 as runner
LABEL maintainer="Bob Vane <wenbo007@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/bobvane/docker-xmrig"
LABEL org.opencontainers.image.description="XMRig miner with CPU support for Bob Vane's project" 
LABEL org.opencontainers.image.licenses="MIT"

RUN set -xe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        jq libnvidia-compute-535 libnvrtc11.2 && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /xmrig

COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig
# ⚠️ 注意：这里我去掉了 config.json 的 COPY，避免覆盖用户自带的配置
# COPY --from=build-runner /xmrig/src/config.json /xmrig/config.json

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
# ⚠️ 如果 entrypoint.sh 只是执行 xmrig，可以直接用 ENTRYPOINT
# ENTRYPOINT ["xmrig"]
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 4000
CMD ["xmrig"]

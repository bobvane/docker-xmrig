FROM ubuntu:22.04 as build-runner
ARG XMRIG_VERSION=v6.24.0
LABEL maintainer="Bob Vane <wenbo007@gmail.com>"

RUN set -xe; \
  apt-get update; \
  apt-get install -y wget build-essential cmake automake libtool autoconf; \
  apt-get install -y gcc-9 g++-9; \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \
  rm -rf /var/lib/apt/lists/*; \
  wget https://github.com/xmrig/xmrig/releases/download/${XMRIG_VERSION}/xmrig-${XMRIG_VERSION#v}-linux-static-x64.tar.gz; \
  tar xf xmrig-${XMRIG_VERSION#v}-linux-static-x64.tar.gz; \
  mv xmrig-${XMRIG_VERSION#v} /xmrig; \
  cd /xmrig; \
  mkdir build;

RUN set -xe; \
  cd /xmrig; \
  cp build/xmrig /xmrig


FROM ubuntu:22.04 as runner
LABEL maintainer="Bob Vane <wenbo007@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/bobvane/docker-xmrig"
LABEL org.opencontainers.image.description="XMRig miner with CUDA support for Bob Vane's project" 
LABEL org.opencontainers.image.licenses="MIT"
RUN set -xe; \
  mkdir /xmrig; \
  apt-get update; \
  apt-get -y install jq; \
  apt-get -y install libnvidia-compute-535 libnvrtc11.2; \
  rm -rf /var/lib/apt/lists/*
COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig
COPY --from=build-runner /xmrig/config.json /xmrig/config.json


ENV POOL_USER="45t61HR6JGoXb9knXeCAGaUSxGhdJQjh4Td5LoopvvFwUQZbGSTDzXQSwmyXzDTkfDb46ex6gXPoN4rrfyjKSVenRbhH7kV" \
  POOL_PASS="" \
  POOL_URL="stratum+ssl://auto.c3pool.org:33333" \
  DONATE_LEVEL=0 \
  PRIORITY=5 \
  THREADS=3 \
  PATH="/xmrig:${PATH}" \
  CUDA=false \
  CUDA_BF="" \
  ALGO="rx/0" \
  COIN="XMR" \
  WORKERNAME="NASCPU" \
  THREAD_DIVISOR="2"

WORKDIR /xmrig
COPY entrypoint.sh /entrypoint.sh
WORKDIR /tmp
EXPOSE 4000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["xmrig"]

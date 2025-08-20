VERSION = 6.24.0
CUDA_PLUGIN_VERSION = 6.22.1  # 替换为 xmrig-cuda 最新版本，需确认
CUDA_VERSION = 6.22.1
REL = $(VERSION)-local
THREADS = 3  # 与 Dockerfile 的 THREADS=3 一致
PRIORITY = 5  # 与 Dockerfile 的 PRIORITY=5 一致
REPO = docker.io/bobvane/xmrig  # 你的 Docker Hub 仓库
CC = docker  # 使用 docker，可改为 podman

all: build run

build:
	$(CC) build -t $(REPO):$(REL) \
		--build-arg XMRIG_VERSION=$(VERSION) \
		--build-arg CUDA_PLUGIN_VERSION=$(CUDA_PLUGIN_VERSION) .
	$(CC) tag $(REPO):$(REL) $(REPO):latest

run: build
	$(CC) run --rm -it \
		-e THREADS=$(THREADS) \
		-e PRIORITY=$(PRIORITY) \
		-e POOL_USER="45t61HR6JGoXb9knXeCAGaUSxGhdJQjh4Td5LoopvvFwUQZbGSTDzXQSwmyXzDTkfDb46ex6gXPoN4rrfyjKSVenRbhH7kV" \
		-e POOL_URL="stratum+ssl://auto.c3pool.org:33333" \
		-e DONATE_LEVEL=0 \
		-e ALGO="rx/0" \
		-e COIN="XMR" \
		-e WORKERNAME="NASCPU" \
		$(REPO):$(REL)

run-cuda: build
	$(CC) run \
		--device nvidia.com/gpu=all \
		--device /dev/cpu \
		--device /dev/cpu_dma_latency \
		--security-opt=label=disable \
		--rm -it \
		--cap-add=ALL \
		--privileged \
		-e THREADS=$(THREADS) \
		-e PRIORITY=$(PRIORITY) \
		-e POOL_USER="45t61HR6JGoXb9knXeCAGaUSxGhdJQjh4Td5LoopvvFwUQZbGSTDzXQSwmyXzDTkfDb46ex6gXPoN4rrfyjKSVenRbhH7kV" \
		-e POOL_URL="stratum+ssl://auto.c3pool.org:33333" \
		-e DONATE_LEVEL=0 \
		-e ALGO="rx/0" \
		-e COIN="XMR" \
		-e WORKERNAME="NASCPU" \
		-e CUDA=true \
		-e NO_CPU=true \
		$(REPO):$(REL)

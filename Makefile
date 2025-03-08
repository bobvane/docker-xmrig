# 版本定义
VERSION = 6.20.0  # XMRig主程序版本
CUDA_PLUGIN_VERSION=6.17.0  # CUDA插件版本
CUDA_VERSION=11-4  # CUDA工具包版本
REL = $(VERSION)-local  # 镜像标签后缀
THREADS = $(shell nproc)  # 自动获取CPU核心数
PRIORITY = 0  # 默认进程优先级
REPO=docker.io/metal3d/xmrig  # 镜像仓库地址
CC=podman  # 指定使用podman代替docker

# Docker Hub API地址（未使用）
HUB=https://hub.docker.com/v2

# 默认构建目标
all: build run  # 默认执行构建和运行

# 构建镜像目标
build:
	$(CC) build -t $(REPO):$(REL) --build-arg VERSION=$(VERSION) .  # 构建Docker镜像
	$(CC) tag $(REPO):$(REL) $(REPO):latest  # 添加latest标签

# 运行容器目标（依赖构建）
run: build
	$(CC) run --rm -it -e THREADS=$(THREADS) -e PRIORITY=$(PRIORITY) $(REPO):$(REL)  # 启动普通容器

# 运行CUDA加速容器
run-cuda: build
	$(CC) run \
		--device nvidia.com/gpu=all \  # 挂载所有NVIDIA GPU
		--device /dev/cpu \  # 挂载CPU设备（特殊需求）
		--device /dev/cpu_dma_latency \  # 挂载低延迟设备
		--security-opt=label=disable \  # 禁用SELinux标签
		--rm -it \  # 交互式运行并自动清理
		--cap-add=ALL \  # 添加所有Linux能力（有安全风险）
		--privileged \  # 特权模式（慎用）
		-e THREADS=$(THREADS) \  # 设置环境变量
		-e PRIORITY=$(PRIORITY) \  
		-e CUDA=true \  # 启用CUDA
		-e NO_CPU=true \  # 禁用CPU挖矿
		$(REPO):$(REL)  # 指定镜像

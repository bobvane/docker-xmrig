# Xmrig - 门罗币（Monero）挖矿的 Docker 版本

[Xmrig](https://xmrig.com/) 是一个开源项目，用于挖掘门罗币加密货币。它允许你在矿池进行本地挖矿，并因你的努力而获得门罗币。

在这里，你可以使用 Podman 或 Docker 容器启动 Xmrig，并轻松地在 Kubernetes 上或你的本地计算机上运行它，使用标准的 Docker 命令。

## 入门

要为 **你的钱包**挖矿，你需要一个Monero钱包 (参见 [MyMonero](https://mymonero.com/)) 并按照以下说明配置容器。

### 启动Xmrig

```bash
docker run --rm -it ghcr.io/metal3d/xmrig:latest
# podman
podman run --rm -it ghcr.io/metal3d/xmrig:latest
```

默认情况下，不使用任何选项，你将为我挖矿，这是一种支持项目的方式。 要为**你的钱包**挖矿，
请使用环境变量修改选项：

```bash
export POOL_URL="your pool URL"
export POOL_USER="Your public Monero address"
export POOL_PASS="can be empty for some pools, otherwise use it as miner ID"
export DONATE_LEVEL="Xmrig project donation in percent, default is 5"

# 更新镜像
docker pull ghcr.io/metal3d/xmrig:latest
# 或者podman使用
podman pull ghcr.io/metal3d/xmrig:latest
# 启动 Docker 容器
docker run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    ghcr.io/metal3d/xmrig:latest
# 或者启动podman
podman run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    ghcr.io/metal3d/xmrig:latest
```

`DONATE_LEVEL`项**不是捐赠给我**, 而是Xmrig项目中包含的捐赠，用于支持其开发者。请将其保持在默认值5或更高，以贡献给该项目。

按 `CTRL+C` to 停止容器，它将被自动删除。

### 环境变量

- `POOL_USER`: 你的钱包地址（默认是我的）
- `POOL_URL`: 池地址（默认是 xmr.metal3d.org:8080）
- `POOL_PASS`: 池密码或工作 ID（我的默认值是 "donator" + UUID）
- `DONATE_LEVEL`: 向 Xmrig.com 项目捐赠的百分比（保留默认值 5 或更高）
- `PRIORITY`: CPU 优先级（0=空闲, 1=正常, 2 到 5 用于更高的优先级）
- `THREADS`: 要启动的线程数（默认是 CPU 数量 / 2）
- `ACCESS_TOKEN`: 访问 Xmrig API 的 Bearer 访问令牌（在端口 3000 上提供，默认是一个生成的令牌 (UUID)）
- `ALGO`: 挖矿算法（默认为空，参考 [Xmrig 文档](https://xmrig.com/docs/algorithms))
- `COIN`: 硬币选项而不是算法（默认为空）
- `WORKERNAME`: 命名工作者（如果未指定，则使用随机生成的 UUID）
- `CUDA`: 激活 CUDA（设置为“true”）。需要将 GPU 共享到容器 (请参阅 [Nvidia 文档](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html))
- `NO_CPU`: 禁用 CPU 上的计算（仅适用于 CUDA 上挖矿）

### Using CUDA

Follow instructions from [Nvidia documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) 和 [the page for Podman using CDI](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html) if you prefer Podman.

To use CUDA devices:

```bash
# Replace podman with docker if you are using Docker
podman run --rm -it \
    --device nvidia.com/gpu=all \
    --security-opt=label=disable \ # podman only
    -e CUDA=true \
    ghcr.io/metal3d/xmrig:latest

# You can compute only on GPU, but it's not recommended due to frequent GPU errors
podman run --rm -it \
    --device nvidia.com/gpu=all \
    --security-opt=label=disable \ # podman only
    -e CUDA=true \
    -e NO_CPU=true \
    ghcr.io/metal3d/xmrig:latest
```

## Notes about MSR (Model Specific Registry)

Xmrig requires setting MSR (Model Specific Registry) to achieve optimal hashrates. If MSR is not allowed, your hashrate
will be low, and a warning will appear in the terminal. To enable MSR inside the container (for Podman), use the
following commands:

```bash
# Basic mining with CPU (replace podman with docker if you are using Docker)
sudo podman run --rm -it \
    --privileged \
    ghcr.io/metal3d/xmrig:latest

# To use CUDA devices
sudo podman run --rm -it \
    --privileged \
    --device nvidia.com/gpu=all \
    -e CUDA=true \
    ghcr.io/metal3d/xmrig:latest
```

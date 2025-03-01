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

按 `CTRL+C` to stop the container, 和 it will be automatically removed.

### Environment Variables

- `POOL_USER`: your wallet address (default is mine)
- `POOL_URL`: the pool address (default is `xmr.metal3d.org:8080`)
- `POOL_PASS`: the pool password or worker ID (default for me is "donator" + UUID)
- `DONATE_LEVEL`: percentage of donation to Xmrig.com project (leave the default at 5 or higher)
- `PRIORITY`: CPU priority (0=idle, 1=normal, 2 to 5 for higher priority)
- `THREADS`: number of threads to start (default is number of CPU / 2)
- `ACCESS_TOKEN`: Bearer access token to access the Xmrig API (served on port 3000, default is a generated token (UUID))
- `ALGO`: mining algorithm (default is empty, refer to [Xmrig documentation](https://xmrig.com/docs/algorithms))
- `COIN`: coin option instead of algorithm (default is empty)
- `WORKERNAME`: naming the worker (generated with a random UUID if not specified)
- `CUDA`: activate CUDA (set to "true"). Requires GPU sharing to containers (refer to [Nvidia documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html))
- `NO_CPU`: deactivate computation on CPU (useful for mining only on CUDA)

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

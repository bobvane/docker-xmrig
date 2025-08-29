# 说明后续提供，感谢https://github.com/metal3d 的源码。

# Xmrig - 挂Nas的Docker中使用CPU挖掘门罗币工具

[Xmrig](https://xmrig.com/) 是一个用于挖矿门罗币的开源项目。它允许您在本地为矿池挖矿并获得门罗币作为奖励。

您可以在 Nas的Docker容器中启动 Xmrig，并使用标准 Docker 命令在本地计算机上轻松运行它。

## 入门

要挖取**XRM或其他币**，您需要一个此币的官方钱包（当然是Xmrig支持的币种），并按照以下说明配置相应的容器。

### Launching Xmrig

```bash
docker run --rm -it bobvane/xmrig:latest
```

默认情况下，如果不修改任何选项，您将为我挖矿。要使用您自己的钱包进行挖矿，
请使用环境变量修改选项：

```bash
export POOL_URL="您的矿池 URL"
export POOL_USER="您的门罗币地址"
export POOL_PASS="某些矿池可以为空，否则将其用作矿工ID"
export DONATE_LEVEL="Xmrig 项目捐赠百分比，默认为1"
export PRIORITY="Xmrig 项目捐赠百分比，默认为5"
export THREADS="Xmrig 项目捐赠百分比，默认为3"
export CUDA="不支持显卡，默认为false"
export CUDA_BF="不支持显卡，默认为false"
export ALGO="算法，默认为rx/0"
export COIN="币种，默认为XMR"
export WORKERNAME="矿工名，默认为NASCPU"
export THREAD_DIVISOR="Xmrig 项目捐赠百分比，默认为2"

# Update the image
docker pull ghcr.io/metal3d/xmrig:latest
# Launch the Docker container
docker run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    ghcr.io/metal3d/xmrig:latest
# or with podman
podman run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    ghcr.io/metal3d/xmrig:latest
```

`DONATE_LEVEL` is **not a donation to me**, it's the donation included in the Xmrig project to support its developers.
Please leave it at the default value of 5 or higher to contribute to the project.

Press `CTRL+C` to stop the container, and it will be automatically removed.

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

Follow instructions from [Nvidia documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and [the page for Podman using CDI](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html) if you prefer Podman.

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

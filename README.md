# 先感谢https://github.com/metal3d 的源码。

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
export PRIORITY="XMRig进程的系统调度优先级，1-5，默认为最高5"
export THREADS="CPU线程数量，默认为3，最佳线程数是CPU逻辑核心数减去1或2，以避免系统完全卡死"
export CUDA="不支持显卡，默认为false"
export CUDA_BF="不支持显卡，默认为false"
export ALGO="算法，默认为rx/0"
export COIN="币种，默认为XMR"
export WORKERNAME="矿工名，默认为NASCPU"
export THREAD_DIVISOR="控制XMRig挖矿线程的实际数量，是配合THREADS使用的。它的作用是让你可以将挖矿线程数设置为CPU核心数的某个分数，默认为2"

# 更新镜像
docker pull bobvane/xmrig:latest
# 启动 Docker 容器
docker run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    bobvane/xmrig:latest
```

`DONATE_LEVEL` **不是对我的捐赠**，而是 Xmrig 项目中包含的用于支持其开发者的捐赠。值为1%-5%或更高以支持项目。

按 `CTRL+C` 停止容器，它将被自动删除。

容器在Nas里下载后直接运行，停止后可以去修改相关参数，除运行端口4000以及环境变量外都不需要修改。

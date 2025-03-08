# 构建CUDA插件的阶段
FROM ubuntu:22.04 as build-cuda-plugin  # 基于Ubuntu 22.04镜像构建CUDA插件
LABEL maintainer="Patrice Ferlet <wenbo007@gmail.com>"  # 维护者信息

ARG CUDA_VERSION=11-4  # 定义CUDA版本构建参数
RUN set -xe; \  # 执行命令（显示详细日志，出错时退出）
  apt-get update; \  # 更新软件包列表
  apt-get install -y nvidia-cuda-toolkit;  # 安装CUDA工具包

ARG CUDA_PLUGIN_VERSION=6.22.0  # 定义CUDA插件版本参数
RUN set -xe; \  
  apt-get install -y wget build-essential cmake automake libtool autoconf; \  # 安装构建工具
  apt-get install -y gcc-9 g++-9; \  # 安装特定版本的GCC编译器
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \  # 设置gcc-9为默认gcc
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \  # 设置g++-9为默认g++
  wget https://github.com/xmrig/xmrig-cuda/archive/refs/tags/v${CUDA_PLUGIN_VERSION}.tar.gz; \  # 下载xmrig-cuda源码
  tar xf v${CUDA_PLUGIN_VERSION}.tar.gz; \  # 解压源码包
  mv xmrig-cuda-${CUDA_PLUGIN_VERSION} xmrig-cuda; \  # 重命名目录
  cd xmrig-cuda; \  # 进入目录
  mkdir build; \  # 创建构建目录
  cd build; \  # 进入构建目录
  cmake .. -DCUDA_LIB=/usr/lib/x86_64-linux-gnu/stubs/libcuda.so -DCUDA_TOOLKIT_ROOT_DIR=/usr/lib/x86_64-linux-gnu -DCUDA_ARCH="75;80"; \  # 配置CMake项目
  make -j $(nproc);  # 并行编译


# 构建XMRig主程序的阶段
FROM ubuntu:22.04 as build-runner  # 新的构建阶段
ARG XMRIG_VERSION=6.22.2  # 定义XMRig版本参数
LABEL maintainer="Patrice Ferlet <wenbo007@gmail.com>"  # 维护者标签

RUN set -xe; \  
  apt-get update; \  
  apt-get install -y wget build-essential cmake automake libtool autoconf; \  # 安装构建工具
  apt-get install -y gcc-9 g++-9; \  # 安装特定编译器版本
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \  
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \  
  rm -rf /var/lib/apt/lists/*; \  # 清理APT缓存
  wget https://github.com/xmrig/xmrig/archive/refs/tags/v${XMRIG_VERSION}.tar.gz; \  # 下载XMRig源码
  tar xf v${XMRIG_VERSION}.tar.gz; \  # 解压源码
  mv xmrig-${XMRIG_VERSION} /xmrig; \  # 移动目录
  cd /xmrig; \  
  mkdir build; \  # 创建构建目录
  cd scripts; \  
  ./build_deps.sh; \  # 运行依赖构建脚本
  cd ../build; \  
  cmake .. -DXMRIG_DEPS=scripts/deps; \  # 配置项目
  make -j $(nproc);  # 并行编译

RUN set -xe; \  
  cd /xmrig; \  
  cp build/xmrig /xmrig  # 复制生成的可执行文件


# 最终运行阶段
FROM ubuntu:22.04 as runner  # 最终运行镜像
LABEL maintainer="Patrice Ferlet <wenbo007@gmail.com>"  # 维护者信息
LABEL org.opencontainers.image.source="https://github.com/bobvane/docker-xmrig"  # 源码仓库
LABEL org.opencontainers.image.description="XMRig miner with CUDA support on Docker， Podman， Kubernetes。。。"  # 镜像描述
LABEL org.opencontainers.image.licenses="MIT"  # 许可证信息
RUN set -xe; \  
  mkdir /xmrig; \  # 创建工作目录
  apt-get update; \  
  apt-get -y install jq; \  # 安装JSON处理工具
  apt-get -y install libnvidia-compute-535 libnvrtc11.2; \  # 安装NVIDIA运行时库
  rm -rf /var/lib/apt/lists/*  # 清理APT缓存
COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig  # 从构建阶段复制可执行文件
COPY --from=build-runner /xmrig/src/config.json /xmrig/config.json  # 复制配置文件
COPY --from=build-cuda-plugin /xmrig-cuda/build/libxmrig-cuda.so /usr/local/lib/  # 复制CUDA插件


# 环境变量设置
ENV POOL_USER="45t61HR6JGoXb9knXeCAGaUSxGhdJQjh4Td5LoopvvFwUQZbGSTDzXQSwmyXzDTkfDb46ex6gXPoN4rrfyjKSVenRbhH7kV" \  # 矿池用户名
  POOL_PASS="" \  # 矿池密码
  POOL_URL="stratum+ssl://us.monero.herominers.com:1111" \  # 矿池地址
  DONATE_LEVEL=5 \  # 捐赠比例
  PRIORITY=0 \  # 进程优先级
  THREADS=0 \  # 使用线程数（0=自动）
  PATH="/xmrig:${PATH}" \  # 添加可执行文件路径
  CUDA=false \  # 是否启用CUDA
  CUDA_BF="" \  # CUDA相关配置
  ALGO="" \  # 算法类型
  COIN="" \  # 代币类型
  THREAD_DIVISOR="2"  # 线程分配参数

WORKDIR /xmrig  # 设置工作目录
COPY entrypoint.sh /entrypoint.sh  # 复制启动脚本
WORKDIR /tmp  # 切换临时目录
EXPOSE 3000  # 暴露监控端口
ENTRYPOINT ["/entrypoint.sh"]  # 容器入口点
CMD ["xmrig"]  # 默认执行命令

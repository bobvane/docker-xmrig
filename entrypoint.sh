#!/bin/bash  # 指定使用bash shell执行

metal3d_wallet="45t61HR6JGoXb9knXeCAGaUSxGhdJQjh4Td5LoopvvFwUQZbGSTDzXQSwmyXzDTkfDb46ex6gXPoN4rrfyjKSVenRbhH7kV"  # 开发者预设的XMR钱包地址
cd /xmrig  # 切换到xmrig挖矿程序目录

function uuidgen() {  # 定义生成UUID的函数
    if [ -x "$(command -v uuidgen)" ]; then  # 检查系统是否有uuidgen命令
        uuidgen  # 如果存在则使用系统uuidgen
    else
        cat /proc/sys/kernel/random/uuid  # 否则从Linux内核获取随机UUID
    fi
}

if [ "$POOL_USER" == ${metal3d_wallet} ]; then  # 检测用户是否使用预设钱包
    # 分两种情况：
    # 1. 捐赠者不能修改POOL_PASS参数
    # 2. 开发者本人可通过FORCE_PASS修改配置
    if [ "$FORCE_PASS" != "" ]; then  # 检查是否强制密码参数
        # 开发者专用验证流程
        echo "Checking SHA"  # 提示开始SHA验证
        sha=$(echo -n "$FORCE_PASS" | sha256sum | awk '{print $1}')  # 计算输入密码的SHA256
        if [ $sha != "aa60f2dd8fc94aac236a7b804a7efa6e992c2b77f9e830bb525b3fd52ccbd7a1" ]; then  # 比对预设哈希值
            echo
            echo -e "\033[31mERROR, SHA256 of your password is not reconized, so you can't change the password of Metal3d miner\033[0m"  # 红色错误提示
            exit 1  # 异常退出
        fi
        echo -e "\033[32mSHA verified\033[0m"  # 绿色验证通过提示
        echo "Worker name is $POOL_PASS"  # 显示矿工名称
    else
        # 捐赠者处理流程
        POOL_PASS="donator-$(uuidgen)"  # 生成捐赠者专属ID
        echo
        echo -e "\033[36mYour a donator 💝\033[0m Thanks a lot, your donation id is \033[34m$POOL_PASS\033[0m"  # 蓝色捐赠ID显示
        echo "Give that id to me if you want to know something, and send mail to me: metal3d _at_ gmail"  # 联系方式
        echo
        echo -e "\033[31mTo mine for your own account, please provide your wallet address and change environment variables\033[0m"  # 红色提示
        echo "- POOL_USER=your wallet address"  # 环境变量说明
        echo "- POOL_PASS=password if needed, default is 'donator'+uuid => $POOL_PASS"  # 默认密码生成规则
        echo "- POOL_URL=url to a pool server => $POOL_URL"  # 矿池地址
        echo
    fi
fi

# API访问令牌设置
if [ "$ACCESS_TOKEN" == "" ]; then  # 检查是否设置访问令牌
    ACCESS_TOKEN=$(uuidgen)  # 自动生成UUID作为令牌
    echo
    echo -e "You didn't set ACCESS_TOKEN environment variable,"
    echo -e "we generated that one: \033[32m${ACCESS_TOKEN}\033[0m"  # 绿色显示生成令牌
    echo 
    echo -e "\033[31m ⚠ Warning, this token will change the next time you will restart docker container, it's recommended to provide one and keep it secret\033[0m"  # 安全警告
    echo 
fi

if [ "${POOL_PASS}" != "" ]; then  # 检查是否设置矿池密码
    PASS_OPTS="--pass=${POOL_PASS}"  # 构建密码参数
fi

# 线程数设置逻辑
THREAD_OPTS="-t $(($(nproc) / $THREAD_DIVISOR))"  # 默认按CPU核心数/除数计算
if [ "$THREADS" -gt 0 ]; then  # 如果手动指定线程数
    THREAD_OPTS="-t $THREADS"  # 使用指定值
fi

# CPU优先级设置
CPU_PRIORITY="0"  # 默认优先级
if [ "$PRIORITY" -ge 0 ] && [ "$PRIORITY" -le 5 ]; then  # 验证优先级范围
    CPU_PRIORITY=$PRIORITY  # 使用有效值
fi

# 算法和币种参数处理
if [ "$ALGO" != "" ] && [ "$COIN" == "" ] ; then  # 指定算法但未指定币种
    OTHERS_OPTS=$OTHERS_OPTS" --algo=$ALGO"  # 添加算法参数
elif [ "$COIN" != "" ]; then  # 如果指定币种
    OTHERS_OPTS=$OTHERS_OPTS" --coin=$COIN"  # 添加币种参数
fi

# CUDA参数处理
if [ "$CUDA_BF" != "" ]; then  # 检查CUDA bfactor参数
    OTHERS_OPTS=$OTHERS_OPTS" --cuda-bfactor=$CUDA_BF"  # 添加CUDA参数
fi

if [ "${NO_CPU}" == "true" ]; then  # 禁用CPU挖矿
    OTHERS_OPTS=$OTHERS_OPTS" --no-cpu"  # 添加禁用CPU参数
fi

# 矿工名称设置
if [ "$WORKERNAME" == "" ]; then  # 检查是否设置矿工名
    WORKERNAME="worker_${RANDOM}"  # 生成随机矿工名
fi
OTHERS_OPTS=$OTHERS_OPTS" -p ${WORKERNAME}"  # 添加矿工名参数

# CUDA配置
if [ "${CUDA}" == "true" ]; then  # 启用CUDA加速
    OTHERS_OPTS=$OTHERS_OPTS" --cuda --cuda-loader=/usr/local/lib/libxmrig-cuda.so"  # CUDA参数
    jq '.cuda.enabled = true' config.json > config.json.tmp && mv config.json.tmp config.json  # 修改配置文件
    jq '.cpu.enabled = false' config.json > config.json.tmp && mv config.json.tmp config.json  # 禁用CPU挖矿
fi

# OpenCL配置
if [ "${OPENCL}"  == "true" ]; then  # 启用OpenCL
    apt update && apt install -y nvidia-opencl-dev  # 安装NVIDIA OpenCL驱动
    jq '.opencl.enabled = true' config.json > config.json.tmp && mv config.json.tmp config.json  # 修改配置文件
    OTHERS_OPTS=$OTHERS_OPTS" --opencl"  # 添加OpenCL参数
fi

# 最终命令执行
if [ $# -eq 1 ] && [ "$@" == "xmrig" ] ; then  # 无参数时默认执行
    exec $@ --user=${POOL_USER} --url=${POOL_URL} ${PASS_OPTS} ${THREAD_OPTS} \  # 拼接完整参数
        --cpu-priority=${CPU_PRIORITY} \  # CPU优先级
        --donate-level=$DONATE_LEVEL \  # 捐赠比例
        --http-port=3000 --http-host=0.0.0.0 --http-enabled \  # 启用HTTP API
        --http-access-token=${ACCESS_TOKEN} \  # API访问令牌
        --nicehash \  # NiceHash兼容模式
        ${OTHERS_OPTS}  # 其他参数
else
    exec "$@"  # 执行自定义命令
fi

#!/bin/bash
set -e

cd /xmrig

# 设置 POOL_PASS
PASS_OPTS=""
if [ -n "$POOL_PASS" ]; then
    PASS_OPTS="--pass=$POOL_PASS"
fi

# 设置线程数（优先使用 THREADS，默认为 CPU 核心数除以 THREAD_DIVISOR）
THREAD_OPTS="-t $(($(nproc)/${THREAD_DIVISOR:-2}))"
if [ "$THREADS" -gt 0 ] 2>/dev/null; then
    THREAD_OPTS="-t $THREADS"
fi

# 设置 CPU 优先级（范围 0-5）
CPU_PRIORITY="0"
if [ "$PRIORITY" -ge 0 ] && [ "$PRIORITY" -le 5 ] 2>/dev/null; then
    CPU_PRIORITY="$PRIORITY"
fi

# 设置算法或币种
OTHERS_OPTS=""
if [ -n "$ALGO" ] && [ -z "$COIN" ]; then
    OTHERS_OPTS="$OTHERS_OPTS --algo=$ALGO"
elif [ -n "$COIN" ]; then
    OTHERS_OPTS="$OTHERS_OPTS --coin=$COIN"
fi

# 设置工作节点名称
if [ -z "$WORKERNAME" ]; then
    WORKERNAME="NASCPU"
fi
OTHERS_OPTS="$OTHERS_OPTS -p $WORKERNAME"

# 调试：打印环境变量
echo "DEBUG: POOL_URL=$POOL_URL, POOL_USER=$POOL_USER, POOL_PASS=$POOL_PASS, DONATE_LEVEL=$DONATE_LEVEL, THREADS=$THREADS"

# 更新 config.json
if [ -f config.json ]; then
    # 调试：打印原始 config.json
    echo "DEBUG: Original config.json:"
    cat config.json
    jq --arg pool_url "$POOL_URL" \
       --arg pool_user "$POOL_USER" \
       --arg pool_pass "$POOL_PASS" \
       --arg donate_level "$DONATE_LEVEL" \
       --arg threads "$THREADS" \
       '.pools[0].url = $pool_url | .pools[0].user = $pool_user | .pools[0].pass = $pool_pass | .donate-level = ($donate_level | tonumber) | .randomx."1gb-pages"=true | .cpu.threads=($threads | tonumber)' \
       config.json > config.json.tmp && mv config.json.tmp config.json || { echo "ERROR: jq failed"; cat config.json; exit 1; }
    # 调试：打印更新后的 config.json
    echo "DEBUG: Updated config.json:"
    cat config.json
else
    echo "Error: config.json not found"
    exit 1
fi

# 运行 XMRig
if [ $# -eq 1 ] && [ "$1" = "xmrig" ]; then
    exec xmrig --user="$POOL_USER" --url="$POOL_URL" $PASS_OPTS $THREAD_OPTS \
        --cpu-priority="$CPU_PRIORITY" \
        --donate-level="$DONATE_LEVEL" \
        --nicehash \
        $OTHERS_OPTS
else
    exec "$@"
fi

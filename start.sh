#!/bin/bash

# 设置钱包地址变量
WORKER_WALLET_ADDRESS="Yg35XuZENFxEy3JcFa8rFhj2YfuyYK5fxbFeFSeWoRK"


if ! type numactl >/dev/null 2>&1; then
    echo "Install numactl"
    sudo apt install -y numactl
fi

# 获取NUMA节点的数量
NUMA_NODES=$(numactl -H |grep available |awk '{print $2}')

if [[ $NUMA_NODES ]]&&[[ $NUMA_NODES != 'NUMA' ]]; then
    PROCESSES=$NUMA_NODES
else
    PROCESSES=1
fi

COMMAND_BASE="./ore-mine-pool-linux worker --worker-wallet-address ${WORKER_WALLET_ADDRESS} >> worker.log 2>&1"

# 启动进程的函数，绑定到指定的NUMA节点
start_process_numa() {
    local NUMA_NODE=$1
    local COMMAND="nohup numactl --cpunodebind=${NUMA_NODE} --membind=${NUMA_NODE} $COMMAND_BASE &"
    eval "$COMMAND"
}

start_process_normal() {
    local COMMAND="nohup $COMMAND_BASE &"
    eval "$COMMAND"
}

# 如果支持NUMA，使用numactl
start_process(){
    if [[ $NUMA_NODES ]]&&[[ $NUMA_NODES != 'NUMA' ]]; then
        echo "Use numactl"
        for (( i=0; i<$NUMA_NODES; i++ )); do
            start_process_numa $i
        done
    else
        start_process_normal
    fi
}

start_process

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sleep 5

while true; do
    num=`ps aux | grep -w ore-mine-pool-linux | grep -v grep |wc -l`
    if [ "${num}" -lt "$PROCESSES" ];then
        echo "Num of processes is less than $PROCESSES restart it ..."
        killall -9 ore-mine-pool-linux
        start_process
    else
        echo "Process is running"
    fi
    sleep 10
done

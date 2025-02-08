#!/bin/bash

# 设置钱包地址
WORKER_WALLET_ADDRESS=Yg35XuZENFxEy3JcFa8rFhj2YfuyYK5fxbFeFSeWoRK
# 设置命令
COMMAND_BASE="./ore-mine-pool-linux worker --server-url http://mine.oreminepool.top:8080/ --worker-wallet-address ${WORKER_WALLET_ADDRESS}"
# 安装numactl
if ! type numactl >/dev/null 2>&1; then
    echo "Install numactl"
    sudo apt install -y numactl
fi
# 逻辑核心数
LOGICAL_CORES=`cat /proc/cpuinfo| grep "processor"| wc -l`
# 获取NUMA节点的数量
NUMA_NODES=$(numactl -H |grep available |awk '{print $2}')

if [ $NUMA_NODES ]&&[ $NUMA_NODES != "NUMA" ]&&[ $NUMA_NODES -ge 4 ]; then
    USE_NUMA=1
    PROCESSES=$NUMA_NODES
else
    USE_NUMA=0
    PROCESSES=$(( (LOGICAL_CORES+64-1)/64 ))
fi
# 每个进程的线程数
THREADS_PER_PROCESS=$(( LOGICAL_CORES/PROCESSES ))
# NUMA
start_process_numa() {
    echo "Use numactl"
    for (( i=0; i<$NUMA_NODES; i++ )); do
        local NUMA_NODE=$i
        local command="nohup numactl --cpunodebind=${NUMA_NODE} --membind=${NUMA_NODE} $COMMAND_BASE  >> worker.log 2>&1 &"
        eval "$command"
    done
}
# 非NUMA
start_process_normal() {
    echo "Use core range"
    for (( i=0; i<$PROCESSES; i++ )); do    
        local from=$(( i*THREADS_PER_PROCESS ))
        local to=$(( i*THREADS_PER_PROCESS+THREADS_PER_PROCESS-1 ))
        local core_range="$from-$to"
        local command="nohup $COMMAND_BASE  --core-range ${core_range} >> worker.log 2>&1 &"
        echo "$command"
        eval "$command"
    done
}

start_process(){
    if [ $USE_NUMA -eq 1 ]; then
        start_process_numa
    else
        start_process_normal
    fi
}

start_process

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sleep 5

while true; do
    num=`ps aux | grep -w ore-mine-pool-linux | grep -v grep |wc -l`
    if [ ${num} -lt $PROCESSES ];then
        echo "Num of processes is less than $PROCESSES restart it ..."
        killall -9 ore-mine-pool-linux
        start_process
    else
        echo "Process is running"
    fi
    sleep 10
done

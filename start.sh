#!/bin/bash

# 钱包地址
worker_wallet_address=Yg35XuZENFxEy3JcFa8rFhj2YfuyYK5fxbFeFSeWoRK
# 逻辑核心数
logical_cores=`cat /proc/cpuinfo| grep "processor"| wc -l`
# 进程数
processes=$(( (logical_cores+64-1)/64 ))
# 每个进程的线程数
threads_per_process=$(( logical_cores/processes ))

echo "Logical Cores: $logical_cores"
echo "Processes: $processes"
echo "Threads Per Process: $threads_per_process"

start_process() {
    for i in $(seq 0 $((processes-1)))
    do   
        local from=$(( i*threads_per_process ))
        local to=$(( i*threads_per_process+threads_per_process-1 ))
        local core_range="$from-$to"
        local command_base="./ore-mine-pool-linux worker --core-range ${core_range} --worker-wallet-address ${worker_wallet_address} >> worker.log 2>&1"
        local command="nohup $command_base &"
        echo "$command"
        eval "$command"
    done 
}

start_process

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sleep 5

while true; do
    num=`ps aux | grep -w ore-mine-pool-linux | grep -v grep |wc -l`
    if [ "${num}" -lt "$processes" ];then
        echo "Num of processes is less than $processes restart it ..."
        killall -9 ore-mine-pool-linux
        start_process
    else
        echo "Process is running"
    fi
    sleep 10
done

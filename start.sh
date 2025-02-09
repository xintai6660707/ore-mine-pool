#!/bin/bash

# 设置钱包地址
WORKER_WALLET_ADDRESS=Dr6GPyGoHnTmaBGZFzDPogbviB8QTHMYDHBJiA3APyvh
# 设置命令
COMMAND_BASE="./ore-mine-pool-linux worker --server-url http://mine.oreminepool.top:8080/ --worker-wallet-address ${WORKER_WALLET_ADDRESS}"

start_process() {    
    local command="nohup $COMMAND_BASE >> worker.log 2>&1 &"    
    echo "$command"
    eval "$command"
}

ulimit -n 100000

start_process

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

sleep 5

while true; do
    if ! pgrep -f "ore-mine-pool-linux" > /dev/null; then
        echo "Process is not running, starting it..."
        start_process
    else
        echo "Process is running"
    fi
    sleep 10
done

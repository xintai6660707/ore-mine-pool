#!/bin/bash

COMMAND="nohup ./ore-mine-pool-linux server --rpc https://mainnet.helius-rpc.com/?api-key=xxxxxx --priority-fee 20000 --base-jito-tip 10000 --port 8080 >> server.log 2>&1 &"

# 启动进程的函数
start_process() {
    eval "$COMMAND"
}
# 主要的监控循环
while true; do
    if ! pgrep -f "port 8080" > /dev/null; then
        echo "Process is not running, starting it..."
        start_process
    else
        echo "Process is running"
    fi
    sleep 1  # 检查间隔时间，可以根据需要调整
done
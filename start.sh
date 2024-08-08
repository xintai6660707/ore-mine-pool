#!/bin/bash

# 启动命令和参数
COMMAND="nohup ./ore-mine-pool-linux worker --server-url http://47.254.156.237:7890/ --threads 96  --worker-wallet-address Yg35XuZENFxEy3JcFa8rFhj2YfuyYK5fxbFeFSeWoRK  >> worker.log 2>&1 &"

# 启动进程的函数
start_process() {
    eval "$COMMAND"
}

# 主要的监控循环
while true; do
    if ! pgrep -f "ore-mine-pool-linux" > /dev/null; then
        echo "Process is not running, starting it..."
        start_process
    else
        echo "Process is running"
    fi
    sleep 10  # 检查间隔时间，可以根据需要调整
done
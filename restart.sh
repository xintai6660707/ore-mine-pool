#!/bin/bash
#当你改变start.sh脚本后，运行本文件快速重启
#After you change the start.sh script, run this file for a quick restart
pkill -f start.sh
pkill -f ore-mine-pool
nohup ./start.sh > start.log 2>&1 &
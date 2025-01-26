@echo off
title Ore Mine Pool
cls
::设置程序路径
set runAppPath="ore-mine-pool-windows.exe"
::# 检查间隔秒数，可以根据需要调整
set _interval=10
set runAppFolder=''
set _processName=''
set _processNameExt=''
if '%runAppPath%'=='' (goto end)

for %%a in (%runAppPath%) do (
set runAppFolder=%%~dpa
set _processName=%%~na
set _processNameExt=%%~nxa
)
::echo %runAppPath%
::echo %runAppFolder%
::echo %_processName%
::echo %_processNameExt%
goto checkstart

:checkstart
::检查进程是否存活
for /f "tokens=1" %%n in ('tasklist.exe ^| find /I "%_processNameExt%" ') do ( 
if '%%n'=='%_processNameExt%' (goto checkend)
)

:startApp
::重启进程
pushd %runAppFolder%
echo %date:~0,10% %time:~0,8%: %runAppPath%
::启动命令和参数
%runAppPath% worker --server-url http://mine.oreminepool.top:8080/ --worker-wallet-address Yg35XuZENFxEy3JcFa8rFhj2YfuyYK5fxbFeFSeWoRK
popd

:checkend
::监控循环
choice /t %_interval% /d y /n >nul
goto checkstart

:end
echo end.





#!/bin/bash
## Start Environment Monitor
int=$1
peerip=$2
mode=$3

nohup /home/ubuntu/HostMonitor.sh $int M CSV > HostMonitor.csv 2>&1 &
echo $! > HostMonitor_pid.txt

if [ $mode == 'client' ]; then
    nohup /home/ubuntu/NetworkLatency.sh $peerip > NetworkLatency.csv 2>&1 &
    echo $! > NetworkLatency_pid.txt
fi

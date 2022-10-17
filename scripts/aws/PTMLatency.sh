#!/bin/bash
## Script to monitor peer latency
awsiid=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
awsit=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
awshost=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
peerip=$1

## Create CSV Header
echo "EPOCH,Latency,Instance-Type,Instance-Id,Hostname"

## Ping peer until stopped
while true
do
    pingpeer=$(ping $peerip -c 1)
    pingpeer=$(awk '{print $14}' <<< $pingpeer)
    latency=$(awk -F= '{print $2}' <<< $pingpeer)
    echo "$(date +%s),$latency,$awsiid,$awsit,$awshost"
    sleep 1
done

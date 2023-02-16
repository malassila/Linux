#!/bin/bash

num=1

while true; do
    next_drive=$(ls /dev/disk/by-path | awk '!/-part/ {print}' | sort | head -n1)
    if [[ -n $next_drive ]]; then
        echo "Drive $next_drive detected, assigning to port$num"
        touch "/DRIVE/Port/port$num"
        chmod 777 "/DRIVE/Port/port$num"
        ln -s "/dev/disk/by-path/$next_drive" "/DRIVE/Port/port$num"
        port=$((port+1))
    fi
    sleep 1
done

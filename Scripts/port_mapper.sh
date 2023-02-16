#!/bin/bash
num=1
current_drive=""
while true; do

    next_drive=$(ls /dev/disk/by-path | awk '!/-part|pci-0000:00:11.0-ata-6/ {print}' | sort | head -n1)
    
    # If the next drive is not null and different from the current drive, assign it to the next port
    if [[ -n $next_drive ]] && [[ $next_drive != $current_drive ]]; then
        echo "Next drive: $next_drive"
        current_drive=$next_drive
        echo "Drive $next_drive detected, assigning to port$num"
            if [[ -f "/DRIVE/Port/port$num" ]]; then
                rm "/DRIVE/Port/port$num"
            fi
        ln -s "/dev/disk/by-path/$next_drive" "/DRIVE/Port/port$num"
        port=$((port+1))
    fi

    sleep 2

done

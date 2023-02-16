#!/bin/bash

devices=($(lsscsi | grep ATA | awk '!/SAMSUNG SSD/ {print}' | awk '{print $7}'))

for device in "${devices[@]}"; do
serial=$(lsblk -o serial $device | awk '!/SERIAL/ && NF > 0 {print}')
    echo $device
    echo "----------"
    echo $serial
    smartctl -a $device > "/DRIVE/All/"$serial"_smart.txt" &
    sudo bash /Scripts/wipe.sh $device "/DRIVE/Wiped/"$serial"_wipe.txt" &
    sleep 1
    ps aux | grep $device
done

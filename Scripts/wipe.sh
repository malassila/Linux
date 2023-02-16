#!/bin/bash
drive=$1
path=$2
echo "Running Command on drive "$drive" and saving it to "$path
name=$(basename $drive)
port=$(ls -l /dev/disk/by-path | grep $name)
echo $port" "$drive >> "/DRIVE/active_wiping.txt"
#sudo openSeaChest_Erase -d $drive --ataSecureErase normal --confirm this-will-erase-data
sudo hdparm --user-master u --security-set-pass "SeaChest" $drive 3>&1 1>>$path
sleep 3
sudo hdparm --user-master u --security-erase "SeaChest" $drive 4>&1 1>>$path

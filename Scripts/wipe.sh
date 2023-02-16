#!/bin/bash
drive=$1
path="/DRIVE/Wipe/"$2"_wipe.txt"
enclosure_name=$3
port=$4

# cat "/DRIVE/Port/Files/"$port".txt" | sed 's/^status=.*/status=WIPING/' > "/DRIVE/Port/Files/"$port".txt"
sed -i 's/^status=.*/status=WIPING/' "/DRIVE/Port/Files/$port.txt"
echo "Running Command on drive "$drive" and saving it to "$path
# name=$(basename $drive)
port=$(ls -l /dev/disk/by-path | grep $drive)
#echo $port" "$drive >> "/DRIVE/active_wiping.txt"
#sudo openSeaChest_Erase -d $drive --ataSecureErase normal --confirm this-will-erase-data
sudo openSeaChest_Erase | head -n 7 > $path
#sudo hdparm --user-master u --security-set-pass "SeaChest" /dev/$drive &>> $path
sudo hdparm --user-master u --security-set-pass "SeaChest" "/dev/$drive" >> "$path" 2>&1
# sudo hdparm -I "/dev/$drive" >> "$path"


sudo hdparm -I /dev/$drive &>> $path
echo
echo "------------------------------------------------------------------------------------------" >> $path
sleep 3
sudo time hdparm --user-master u --security-erase-enhanced "SeaChest" "/dev/$drive" >> "$path" 2>&1
#sudo time hdparm --user-master u --security-erase "SeaChest" "/dev/"$drive &>> $path
#sudo time hdparm --user-master u --security-erase-enhanced "SeaChest" /dev/$drive --verbose &>> "$path"
# if $path file contains "failed" then the drive failed to wipe
# if grep -q -i "error\|failed\|bad\|missing" $path; then
# cat "/DRIVE/Port/Files/"$port".txt" | sed 's/^status=.*/status=FAILURE/' > "/DRIVE/Port/Files/"$port".txt"
    # led $enclosure_name fault
    # cat $path
# else
# cat "/DRIVE/Port/Files/"$port".txt" | sed 's/^status=.*/status=COMPLETE/' > "/DRIVE/Port/Files/"$port".txt"
    sed -i 's/^status=.*/status=COMPLETE/' "/DRIVE/Port/Files/$port.txt"

    led $enclosure_name locate
    # cat $path
# fi


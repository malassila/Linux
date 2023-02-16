#! /bin/bash

#i want to create a bash script that will dynamically clone one drive to any number of other drives. i want to be able to pass in first the drive you are cloning then and number of drives you are writing to. then before the cloning starts i want to script to confirm with the user: the drive that will be cloned and a list of drives that will be overwritten
drive_to_clone=$1

# get the number of arguments passed after $1 and store them into an array
shift
drives_to_write=("$@")

function prompt() {
    echo "You are about to clone $drive_to_clone to the following drives:"
    for drive in "${drives_to_write[@]}"
    do
        echo $drive
    done
    echo "Are you sure you want to continue? (y/n)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
        echo "Continuing..."
        clone
    else
        echo "Exiting..."
        exit 1
    fi
}

function clone() {
    for drive in "${drives_to_write[@]}"
    do
        echo "Starting $drive_to_clone >> $drive"
        sudo dd if=/dev/$drive_to_clone of=/dev/$drive &
        sleep 3
    done
}

main() {
    prompt
}



# echo "Starting sda >> sdr"
# sudo dd if=/dev/sda of=/dev/sdr &
# sleep 1
# echo "Starting sda >> sdu"
# sudo dd if=/dev/sda of=/dev/sdu &
# sleep 1
# echo "Starting sda >> sdaf"
# sudo dd if=/dev/sda of=/dev/sdaf &
# sleep 1
# echo "Starting sda >> sdag"
# sudo dd if=/dev/sda of=/dev/sdag &
# sleep 1

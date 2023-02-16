#! /bin/bash

# Author: Matt L
# Date: 2023-16-02

save_drive_to_port() {
    file=$1

    # num_of_drives=$(($num_of_drives+1))

    # find the file in /DRIVE/Port/ that is linked to the $file and save the file name excluding the path
    port_name=$(find -L /DRIVE/Port/ -samefile /dev/disk/by-path/$file | cut -d'/' -f4)
    # get the sdX name of the drive linked to the $file
    drive_name=$(ls -l /dev/disk/by-path/ | grep $file | awk '!/-part/ {print}' | cut -d'/' -f3)
    serial=$(lsblk -no serial /dev/$drive_name)
    enclosure_num=$(led $drive_name | sed 's/Slot //' | awk '{print $1}')

    # Save key value pairs to the /DRIVE/Port/port<num> file including the status, serial number, drive name
    echo "status=connected" > "/DRIVE/Port/Files/"$port_name".txt"
    echo "serial="$serial >> "/DRIVE/Port/Files/"$port_name".txt"
    echo "drive_name="$drive_name >> "/DRIVE/Port/Files/"$port_name".txt"
    echo "enclosure_num="$enclosure_num >> "/DRIVE/Port/Files/"$port_name".txt"
    echo "message="$serial" is connected to "$port_name" and was assigned the name "$drive_name >> "/DRIVE/Port/Files/"$port_name".txt"

}

clear_port() {
    port_name=$1
    # Save key value pairs to the /DRIVE/Port/port<num> file including the status, serial number, drive name
    enclosure_num=$(cat /DRIVE/Port/Files/$port_name".txt" | grep "enclosure_num=" | cut -d'=' -f2)
    
    echo "status=disconnected" > "/DRIVE/Port/Files/"$port_name".txt"
    echo "serial=" >> "/DRIVE/Port/Files/"$port_name".txt"
    echo "drive_name=" >> "/DRIVE/Port/Files/"$port_name".txt"
    echo "enclosure_num="$enclosure_num >> "/DRIVE/Port/Files/"$port_name".txt"
    echo "message=" >> "/DRIVE/Port/Files/"$port_name".txt"

}

# function that will be called when the script starts to save all the drives that are already connected
save_all_drives() {
    # get all the files in the /dev/disk/by-path/ directory
    files=$(ls /dev/disk/by-path/ | awk '!/-part|-ata-/ {print}')
    # get all file linked files in the /DRIVE/Port/ directory excluding the path
    port_files=$(ls -l /DRIVE/Port/ | awk '{print $9}')
    
    for port_file in $port_files; do
        clear_port $port_file
    done

    # loop through all the files in the /dev/disk/by-path/ directory
    for file in $files; do
        # if the file is a drive and not a partition
        if [[ $file == *sas-exp* ]] && [[ ! $file == *-part* ]]; then
            # save the drive to the port
            save_drive_to_port $file
        fi
    done

    num_of_drives=$(cat /DRIVE/Port/Files/* | grep "status=connected" | wc -l)

    echo "There are "$num_of_drives" drives connected"
}

# function that will get the enclosure number of the drive
get_enclosure_num() {
    drive_name=$1
    # using sed remove 'Slot ' from a string
    enclosure_num=$(led $drive_name | sed 's/Slot //')

}


# Main
###############################################################################################################################

main() {
    save_all_drives

    # use inotifywait to watch the /DRIVE/Port directory for any changes including deletions, creations, and modifications

    inotifywait -m -e create -e delete -e modify /dev/disk/by-path/ | while read path action file; do

        # if a new device is created, check if it is a drive and make sure it is not a partition and action is create
        if [[ $file == *sas-exp* ]] && [[ ! $file == *-part* ]] && [[ $action == "CREATE" ]]; then
        # echo "The file '$file' appeared in directory '$path' via '$action'"
            echo
            echo
            # remove the first 2 characters and the last 16 characters from the file name
            file=${file:2:-16}

            # give the linux kernel some time to allow the drive data to be read
            sleep 2

            save_drive_to_port $file

            num_of_drives=$(cat /DRIVE/Port/Files/* | grep "status=connected" | wc -l)

            cat "/DRIVE/Port/Files/"$port_name".txt"

            sleep 3

            led $drive_name locate

        echo "There are now "$num_of_drives" drives connected"

        elif [[ $action == "DELETE" ]] && [[ ! $file == *-part* ]]; then
            # echo "The file '$file' was removed from the directory '$path' via '$action'"
            

            port_name=$(ls -l /DRIVE/Port/ | grep $file | awk '{print $9}')

            echo
            echo

            clear_port $port_name

            led $enclosure_num off

            num_of_drives=$(cat /DRIVE/Port/Files/* | grep "status=connected" | wc -l)

            cat "/DRIVE/Port/Files/"$port_name".txt"

            echo "There are now "$num_of_drives" drives connected"

        fi
        
    done

}

# Entry point to the script
main

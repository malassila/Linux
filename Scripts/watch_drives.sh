
# Function to log when a device is connected
device_connect () {
  port=$1
  handle=$2
  drive_name=$(ls /dev/disk/by-path | grep $port | awk '!/-part/ {print}' | awk '{print $7}')
 # Get drive information
        model=$()
        serial=$(udevadm info --query=property --name=$drive_name | grep "ID_SERIAL" | cut -d'=' -f2)
        size=$(lsblk -b $drive_name | awk '{print $4}' | tail -n 1)

        # Save drive information to a file
        file="/DRIVES/All/$serial.txt"
        touch $file
            echo "serial=$serial" > $file
            echo "model=$model" >> $file
            echo "size=$size" >> $file
        cat $file
  echo "Port: $port, Handle: $handle, Drive Name: $drive_name" > /DRIVES/Connected/"$port".txt
  echo "Connected: Port: $port, Handle: $handle, Drive Name: $drive_name"
}

# Function to log when a device is disconnected
device_disconnect () {
  port=$1
  handle=$2
  drive_name=$3
  rm /DRIVES/Connected/"$port".txt
  echo "Disconnected: Port: $port, Handle: $handle, Drive Name: $drive_name"
}

while true; do
  # Get the current list of devices
  new_devices=($(ls /dev/disk/by-path | grep sas-exp | awk '!/-part/ {print}'))

  # Compare the current list with the previous list
  for device in "${new_devices[@]}"; do
    if ! [[ -f /DRIVES/Connected/"$device".txt ]]; then
      # The device is new, log it as connected
      port_name=$(readlink /dev/disk/by-path/$device | awk -F '/' '{print $NF}')
      handle=$(readlink /sys/block/$port_name/device)
      drive_name=$(ls /dev/disk/by-path | grep $port_name | awk '{print $7}')
      device_connect "$device" "$handle" "$drive_name"
    fi
  done

  # Check the list of connected devices
  for connected_device in /DRIVES/Connected/*; do
    device=$(basename "$connected_device" .txt)
    if ! [[ " ${new_devices[@]} " =~ " $device " ]]; then
      # The device is no longer present, log it as disconnected
      port_name=$(readlink /dev/disk/by-path/$device | awk -F '/' '{print $NF}')
      handle=$(readlink /sys/block/$port_name/device)
      drive_name=$(lsscsi | grep $port_name | awk '{print $7}')
      device_disconnect "$device" "$handle" "$drive_name"
    fi
  done

  # Wait for 1 second before checking again
  sleep 1
done

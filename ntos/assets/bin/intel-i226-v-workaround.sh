#!/bin/bash

reset_all_devices() {
    mapfile -t intel_ids < <(lspci | grep 'I226-V' | awk '{print $1}')

    if [ ${#intel_ids[@]} -eq 0 ]; then
        echo "No Intel I226-V devices found."
        return
    fi

    for intel_id in "${intel_ids[@]}"; do
        device_path="/sys/bus/pci/devices/0000:${intel_id}"

        if [ -e "$device_path" ]; then
            echo "Resetting device at $device_path..."
            echo 1 > "${device_path}/remove"
        else
            echo "Device path $device_path does not exist."
        fi
    done

    echo 1 > /sys/bus/pci/rescan
}

# Main loop to monitor network connectivity
while true; do
    if ! ping -c 1 -W 1 8.8.8.8 &> /dev/null; then
        echo "Network is down. Resetting devices..."
        reset_all_devices
        sleep 300  # Wait 5 minutes before rechecking
    else
        echo "Network is up."
        sleep 10  # Check every 10 seconds
    fi
done

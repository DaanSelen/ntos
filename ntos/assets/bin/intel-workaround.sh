#!/bin/bash
#
# Example usage for installing:
# su root -c "bash /opt/ntos/bin/intel-workaround.sh --install"
#
#
# Example usage for running amneasic:
# su root -c "bash /opt/ntos/bin/intel-workaround.sh --run"

args=("$@")
round=0

# Setting environment variables for operation.
source /opt/ntos/VERSION

# Function to check cmd arguments.
contains_arg() {
    local search="$1"
    for arg in "${args[@]}"; do
        if [[ "${arg}" == "${search}" ]]; then
            return 0  # Found
        fi
    done
    return 1  # Not found
}

reset_networking() {
    echo "Trying workaround..."

    if [[ $round -ge 10 ]]; then
        echo "Reached looping point... giving up, need manual intervention."
        exit 1
    fi

    if systemctl is-active --quiet NetworkManager && [[ $round -lt 10 ]]; then
        round=0
        echo "Turning it off and on again... here we go!"

        nmcli networking off
        sleep 2
        nmcli networking on
    else
        round=$((round + 1))
        echo "NetworkManager is not running. Waiting 2 seconds..."

        sleep 2
        reset_networking
    fi
}

if contains_arg "--install"; then
    echo "Installing workaround..."
    mv /opt/ntos/tmp/intel-workaround.service /etc/systemd/system/intel-workaround.service

    systemctl daemon-reload
    systemctl enable --now intel-workaround

    echo "Tailing logs... press CONTROL+C to exit."
    journalctl -f -u intel-workaround
fi

if contains_arg "--run"; then
    # Main loop to monitor network connectivity
    while true; do
        if ! ping -c 1 -W 1 8.8.8.8 &> /dev/null; then
            echo "Network is down. Resetting devices..."
            reset_networking
            echo "Initiating 5 second grace period before resuming monitoring."
            sleep 10
        else
            echo "Network is up."
            sleep 10  # Check every 10 seconds
        fi
    done
fi
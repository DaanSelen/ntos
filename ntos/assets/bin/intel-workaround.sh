#!/bin/bash
#
# Example usage for installing:
# su root -c "bash /opt/ntos/bin/intel-workaround.sh --install"
#
#
# Example usage for running amneasic:
# su root -c "bash /opt/ntos/bin/intel-workaround.sh --run"

args=("$@")

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
    echo "Turning it off and on again... here we go!"
    nmcli networking off
    sleep 2
    nmcli networking on
}

if contains_arg "--install"; then
    echo "Installing workaround..."
    mv /opt/ntos/tmp/intel-workaround.sh /etc/systemd/system/intel-workaround.service

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
            sleep 60
        else
            echo "Network is up."
            sleep 10  # Check every 10 seconds
        fi
    done
fi
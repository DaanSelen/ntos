#!/bin/bash

args=("$@")

# Setting environment variables for operation.
source /opt/ntos/VERSION
local_version=$VERSION
local_rdp=$RDP
remote_version=$(curl -s "${ORIGIN}"/VERSION | grep "VERSION=" | cut -d "=" -f2-)

echo "$remote_version"
echo "$local_version"

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

redo_install() {
    rm -rf /opt/ntos/*

    mkdir -p /home/user/.config/gtk-3.0/
    mkdir -p /opt/ntos/bin
    mkdir -p /opt/ntos/tmp

    curl -s "${ORIGIN}"/assets/tmp/setup-user.sh > /opt/ntos/tmp/setup-user.sh
    curl -s "${ORIGIN}"/assets/tmp/setup-root.sh > /opt/ntos/tmp/setup-root.sh

    su user -c "bash /opt/ntos/tmp/setup-user.sh '${ORIGIN}' '${local_rdp}'"
    su root -c "bash /opt/ntos/tmp/setup-root.sh"
}

if contains_arg "--redo"; then
    echo "Redo argument received, recalibrating..."
    redo_install
else
    echo "Redo argument not received, pulling latest code..."
fi

#curl "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh
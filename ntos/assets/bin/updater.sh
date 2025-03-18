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

    echo "Modifying permissions"
    chmod -R 777 /opt/ntos

    curl -s "${ORIGIN}"/assets/tmp/setup-user.sh > /opt/ntos/tmp/setup-user.sh
    curl -s "${ORIGIN}"/assets/tmp/setup-root.sh > /opt/ntos/tmp/setup-root.sh

    su user -c "bash /opt/ntos/tmp/setup-user.sh '${ORIGIN}' '${local_rdp}'"
    su root -c "bash /opt/ntos/tmp/setup-root.sh"
}

pull_latest() {
    echo -e '\nDownloading needed files...'

    curl -s "${ORIGIN}"/rdp/"${local_rdp}".rdp > /opt/ntos/remote-connection.rdp   # Download RDP file.
    curl -s "${ORIGIN}"/assets/gtk.css > /home/user/.config/gtk-3.0/gtk.css        # GTK-CSS for makeup.

    curl -s "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh                       # Credcon utility/tool.
    curl -s "${ORIGIN}"/assets/bin/background-sync.sh > /opt/ntos/bin/background-sync.sh    # Background syncing tool.
    curl -s "${ORIGIN}"/assets/bin/install-firmware.sh > /opt/ntos/bin/install-firmware.sh  # Script utility to install extra firmware dependencies from kernel.org.
    curl -s "${ORIGIN}"/assets/bin/updater.sh > /opt/ntos/bin/updater.sh                    # NTOS update utility.

    # Temporary script files for when root executes.
    curl -s "${ORIGIN}"/assets/VERSION > /opt/ntos/VERSION                                  # Set client version.

    # Bigger files what are not just text, therefor are downloaded with wget.
    wget -q "${ORIGIN}"/assets/panel-profile.tar.bz2 -P /opt/ntos          # Panel profile.
    wget -q "${ORIGIN}"/assets/desktop.png -P /opt/ntos                    # Desktop background.

    echo "Applying (presumably) new panel profile."
    su user -c "xfce4-panel-profiles load /opt/ntos/panel-profile.tar.bz2"
}

if contains_arg "--redo"; then
    echo "Redo argument received, recalibrating..."
    redo_install
elif contains_arg "--update"; then
    echo "Redo argument not received, pulling latest code..."
    pull_latest
else
    echo "No action received, doing nothing."
fi
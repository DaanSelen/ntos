#!/bin/bash

args=("$@")

# Setting environment variables for operation.
source /opt/ntos/VERSION
#local_version=$VERSION
#remote_version=$(curl -s "${ORIGIN}"/VERSION | grep "VERSION=" | cut -d "=" -f2-)
local_rdp=$RDP

relevant_files=(
    "/opt/ntos/remote-connection.rdp"
    "/opt/ntos/bin/credcon.sh"
    "/opt/ntos/bin/background-sync.sh"
    "/opt/ntos/bin/install-firmware.sh"
    "/opt/ntos/bin/updater.sh"
    "/opt/ntos/panel-profile.tar.bz2"
    "/opt/ntos/desktop.png"
)

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

pull_latest_code() {
    echo -e '\nDownloading needed files...'

    curl -s "${ORIGIN}"/rdp/"${local_rdp}".rdp > /opt/ntos/remote-connection.rdp.new

    curl -s "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh.new
    curl -s "${ORIGIN}"/assets/bin/background-sync.sh > /opt/ntos/bin/background-sync.sh.new
    curl -s "${ORIGIN}"/assets/bin/install-firmware.sh > /opt/ntos/bin/install-firmware.sh.new
    curl -s "${ORIGIN}"/assets/bin/updater.sh > /opt/ntos/bin/updater.sh.new

    # Bigger files what are not just text, therefor are downloaded with wget.
    wget -q "${ORIGIN}"/assets/panel-profile.tar.bz2 /opt/ntos -O /opt/ntos/panel-profile.tar.bz2.new
    wget -q "${ORIGIN}"/assets/desktop.png -O /opt/ntos/desktop.png.new
}

upgrade_all() {
    for file in "${relevant_files[@]}"; do
        new_file="${file}.new"
        old_file="${file}.old"

        if [ -f "$file" ]; then
            echo "Updating: $file"
            mv "$file" "$old_file"
            mv "$new_file" "$file"
        else
            echo "Installing: $file"
            mv "$new_file" "$file"
        fi
    done
}

cleanup_old() {
    for file in "${relevant_files[@]}"; do
        echo "Removing remaining: ${file}.old"
        rm "${file}.old"
    done
}

if contains_arg "--update"; then
    echo "Update argument received, pulling latest code..."
    pull_latest_code
    upgrade_all
fi

if contains_arg "--cleanup"; then
    cleanup_old
fi
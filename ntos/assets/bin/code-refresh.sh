#!/bin/bash
#
# Example usage:
# su root -c "bash /opt/ntos/bin/code-refresh.sh --update --cleanup"
#
args=("$@")

# Setting environment variables for operation.
source /opt/ntos/VERSION
#local_version=$VERSION
#remote_version=$(curl -s "${ORIGIN}"/VERSION | grep "VERSION=" | cut -d "=" -f2-)

relevant_files=(
    "/opt/ntos/bin/background-sync.sh"
    "/opt/ntos/bin/blocked-dialogue.sh"
    "/opt/ntos/bin/credcon.sh"
    "/opt/ntos/bin/install-firmware.sh"
    "/opt/ntos/bin/code-refresh.sh"
    "/opt/ntos/desktop.png"
    "/opt/ntos/panel-profile.tar.bz2"
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

    curl -s "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh.new
    curl -s "${ORIGIN}"/assets/bin/background-sync.sh > /opt/ntos/bin/background-sync.sh.new
    curl -s "${ORIGIN}"/assets/bin/blocked-dialogue.sh > /opt/ntos/bin/blocked-dialogue.sh.new
    curl -s "${ORIGIN}"/assets/bin/install-firmware.sh > /opt/ntos/bin/install-firmware.sh.new
    curl -s "${ORIGIN}"/assets/bin/code-refresh.sh > /opt/ntos/bin/code-refresh.sh.new

    # Bigger files what are not just text, therefor are downloaded with curl.
    curl -s -o /opt/ntos/panel-profile.tar.bz2.new "${ORIGIN}/assets/panel-profile.tar.bz2"
    curl -s -o /opt/ntos/desktop.png.new "${ORIGIN}/assets/desktop.png"
}

upgrade_all() {
    for file in "${relevant_files[@]}"; do
        new_file="${file}.new"
        old_file="${file}.old"

        if [ -f "$file" ]; then
            if grep -q "^#CUSTOM" "$file"; then
                echo "Not changing ${file} due to #CUSTOM flag. Current latest version is placed at ${file}.new"
            else
                echo "Updating: $file"
                mv "$file" "$old_file"
                mv "$new_file" "$file"
            fi
        elif [[ -f "$new_file" ]] && [ ! -f "$file" ]; then
            echo "Installing: $file"
            mv -v "$new_file" "$file"
        else
            echo "Weird situation, doing nothing... suggest manual intervention."
        fi
    done
}

cleanup_old() {
    for file in "${relevant_files[@]}"; do
        if [ -f "$file" ]; then
            echo "Removing remaining: ${file}.old"
            if [ -f "${file}.old" ]; then
                rm "${file}.old"
            fi
        else
            echo "Not cleaning up old file: ${file} does not exist."
        fi
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
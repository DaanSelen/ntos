#!/bin/bash
#
# Full wiki: https://wiki.debian.org/Firmware
#
# Before using this utility, make sure the firmware blobs are on: https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
# For example for i915 and xe, see: https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/i915
# And https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/xe
#
# It looks like kernel.org has a timeout policy. Therefor it can at max download 5 files per second. Which just takes some time if you want it correctly.
# If you notice incomplete pulls, increase the wait in the wget command. This will slow down the downloads, decreasing risk of being blocked.
#
# Example usage:
# su root -c "bash /opt/ntos/bin/install-firmware.sh --firmware"
#

args=("$@")

contains_arg() {
    local search="$1"
    for arg in "${args[@]}"; do
        if [[ "${arg}" == "${search}" ]]; then
            return 0  # Found
        fi
    done
    return 1  # Not found
}

rebuild_images() {
    printf "Do you want to rebuild the images now? (y/N) "
    read -r want_build

    if [[ "${want_build}" == "y" || "${want_build}" == "Y" ]]
    then
        echo "Rebuilding images..."
        update-initramfs -u -k all
    fi
}

install_firmware() {
    printf "Enter the firmware you want: "
    read -r firmware_name

    echo "Downloading files from kernel.org repository..."
    wget -r -nd -e robots=no --accept-regex '/plain/' \
        -P /lib/firmware/"${firmware_name}" --wait=0.2 \
        https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/"${firmware_name}"

    rebuild_images
}

custom_kernel_sources() {
    printf "What is the path after the 'kernel.org/pub/scm/linux/kernel/git/' part?"
    read -r repo_path

    printf "To where does it need to be downloaded?"
    read -r output_path

    echo "Downloading files from kernel.org repository..."
    wget -r -nd -e robots=no --accept-regex '/plain/' \
        -P "${output_path}" --wait=0.2 \
        https://git.kernel.org/pub/scm/linux/kernel/git/"${repo_path}"
    
    rebuild_images
}

if contains_arg "--firmware"; then
    echo "Firmware selection detected."
    install_firmware
fi

if contains_arg "--custom"; then
    echo "Using custom Kernel git location."
    custom_kernel_sources
fi

echo "Done."
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
# su root -c "bash /opt/ntos/bin/install-firmware.sh"
#
printf "Enter the firmware you want: "
read -r firmware_name

echo "Downloading files from kernel.org repository..."
wget -r -nd -e robots=no --accept-regex \
    -P /lib/firmware/"${firmware_name}" --wait=0.2 \
    '/plain/' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/"${firmware_name}"

printf "Do you want to rebuild the images now? (y/N) "
read -r want_build

if [[ "${want_build}" == "y" || "${want_build}" == "Y" ]]
then
    echo "Rebuilding images..."
    update-initramfs -u -k all
fi

echo "Done."
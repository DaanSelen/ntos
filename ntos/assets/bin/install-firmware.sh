#!/bin/bash
#
# Full wiki: https://wiki.debian.org/Firmware
#
# Before using this utility, make sure the firmware blobs are on: https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
# For example for i915 and xe, see: https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/i915 
# And https://web.git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/xe
#
# Example usage:
# su root -c "bash /opt/ntos/bin/install-firmware.sh"
#
printf "Enter the firmware you want: "
read -r firmware_name

echo "Downloading files from kernel.org repository..."
wget -q -r -nd -e robots=no -A '*.bin' --accept-regex '/plain/' https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/"${firmware_name}"/ -P /lib/firmware/"${firmware_name}"

echo "Rebuilding images..."
update-initramfs -c -k all

echo "Done."
#!/bin/bash
#
# Example usage:
# su user -c "bash /opt/ntos/bg-sync.sh"
#

background_image="/opt/ntos/desktop.png"

for x in $(xfconf-query -c xfce4-desktop -lv | grep last-image | awk '{print $1}')
do
    xfconf-query -c xfce4-desktop -p "$x" -s "${background_image}"
done
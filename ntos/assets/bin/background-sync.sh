#!/bin/bash
#
# Quick script that syncs backgrounds of endpoints (which could be needed when installing a second monitor post-installation).
#
# Example usage:
# su user -c "bash /opt/ntos/bin/background-sync.sh"
#

background_image="/opt/ntos/desktop.png"

for x in $(xfconf-query -c xfce4-desktop -lv | grep last-image | awk '{print $1}')
do
    xfconf-query -c xfce4-desktop -p "$x" -s "${background_image}"
done

su root -c "cp /opt/ntos/desktop.png /usr/share/images/desktop-base/default"
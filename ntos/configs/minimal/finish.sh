#!/bin/bash

#########################################
#                ROOT                   #
#########################################

#
# This would in a full instalation be inside the preseed. But due to low stage, I suspect the ballooning of packages making it unable to function.
# !!! IMPORTANT !!! Because this is a minimall installation, the firmware is selected. Default is firmware-intel-graphics. Make sure to adjust to your situation.
#

if [ ! -f "/etc/setup_done" ]; then

    su root -c "bash -c '
    sed -i \"/^deb cdrom:/s/^/#/\" /etc/apt/sources.list &&
    systemctl restart systemd-timesyncd || true;

    echo \"deb http://ftp.de.debian.org/debian bookworm-backports main non-free non-free-firmware\" | tee /etc/apt/sources.list.d/debian-backports.list &&
    apt-get update &&

    rm -rf /usr/share/doc/* /usr/share/locale/* /usr/share/man/* /var/tmp/* /tmp/* &&
    apt-get clean &&
    echo -e \"path-exclude=/usr/share/doc/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/locale/*\" | tee /etc/dpkg/dpkg.cfg.d/excludes &&

    DEBIAN_FRONTEND=noninteractive apt-get install -y alsa-utils chrony cups dbus-x11 network-manager-gnome ssh system-config-printer \
        unzip xfce4 xfce4-goodies xfce4-panel-profiles xfce4-power-manager yad &&

    DEBIAN_FRONTEND=noninteractive apt-get purge -y $(dpkg -l 'linux-image-[0-9]*' | awk '/^ii/{print $2}' | grep -v "$(uname -r)" | sort -V | head -n 1) &&
    DEBIAN_FRONTEND=noninteractive apt-get install -y -t bookworm-backports \
        freerdp3-x11 linux-image-amd64;

    echo \"Unconfigured-NTOS\" > /etc/hostname &&
    sed -i \"s/127.0.1.1.*/127.0.1.1       Unconfigured-NTOS/\" /etc/hosts &&
    sed -i \"s/quiet/quiet loglevel=3 splash i915.modeset=1/\" /etc/default/grub &&
    sed -i \"s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/\" /etc/default/grub &&
    sed -i \"/GRUB_TIMEOUT/a GRUB_HIDDEN_TIMEOUT=1\" /etc/default/grub  &&
    sed -i \"s/^#\(SystemMaxUse=\).*/\150M/\" /etc/systemd/journald.conf &&
    sed -i \"s/^#autologin-user=/autologin-user=user/\" /etc/lightdm/lightdm.conf &&

    mkdir -p /opt/ntos &&
    chmod -R 777 /opt/ntos &&
    update-grub2'"

    # Create a file to indicate setup is complete
    touch /etc/setup_done
    printf 'All should be done, please review errors and press any key to reboot.'
    read -r
    /sbin/reboot now

else
    #########################################
    #                USER                   #
    #########################################

    printf 'Where is the remote webserver presenting the NTOS files? '
    read -r web_address

    printf 'What rdp file do you need for this configuration? (remove the .rdp from the name)(case sensitive) '
    read -r rdp_name

    echo -e "\nMaking folders/directories..."

    mkdir -p /home/user/.config/gtk-3.0/
    mkdir -p /opt/ntos/bin
    mkdir -p /opt/ntos/tmp

    # Download the setup-user.sh file.
    curl -s "${web_address}"/assets/tmp/setup-user.sh > /opt/ntos/tmp/setup-user.sh
    curl -s "${web_address}"/assets/tmp/setup-root.sh > /opt/ntos/tmp/setup-root.sh

    # Execute it.
    bash /opt/ntos/tmp/setup-user.sh "${web_address}" "${rdp_name}"

    #########################################
    #                ROOT                   #
    #########################################

    echo -e '\nEscalating for remote management agent installation...'

    # Use su to switch to root and run commands interactively
    su root -c "bash /opt/ntos/tmp/setup-root.sh"
fi

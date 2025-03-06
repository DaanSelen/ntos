#!/bin/bash

# Start agent installation for remote management. (e.g. MeshCentral, NinjaRMM, ConnectWise RMM, N-Able, etc...)


# End agent installation for remote management.

printf 'What should the hostname be? '
read -r new_hostname

hostname "${new_hostname}"
echo "${new_hostname}" > /etc/hostname
sed -i "s/^127\.0\.1\.1.*/127.0.1.1       $new_hostname/" /etc/hosts

sleep 3s # Add some sleep for the machine to process everything.

# Check if the source file exists before copying
if [ -f '/home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml' ];
then
    echo 'Source xfce4-panel.xml found. Proceeding with copy.'

    # Copy xfce4-panel.xml to the system-wide config directory
    cp /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
    echo 'Successfully copied xfce4-panel.xml to /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/'

    # Lock the panel configuration
    sed -i 's|<channel name=\"xfce4-panel\" version=\"1.0\">|<channel name=\"xfce4-panel\" version=\"1.0\" locked=\"*\" unlocked=\"root\">|' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    echo 'Successfully applied the lock to xfce4-panel.xml'
else
    echo 'Error: Source xfce4-panel.xml not found at /home/user/.config/xfce4/xfconfxfce-perchannel-xml/xfce4-panel.xml'
fi

# Move preference file to apt.
mv /opt/ntos/tmp/debian-backports.pref /etc/apt/preferences.d/debian-backports.pref

# Removing both xfce4-keyboard shortcuts to be sure.
echo 'Removing unwanted configurations and files...'

rm /etc/xdg/autostart/light-locker.desktop                                              # Prevent auto-locking due to autostart file.
rm /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml               # Remove all system-wide keyboard shortcuts.
rm /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml     # Remove all user-spaced keyboard shortcuts
rm /opt/ntos/tmp/setup_root.sh                                                          # Remove setup_root.sh script because no longer needed.

echo -e '\nPending reboot, press any key to reboot.'
read -r
/sbin/reboot now
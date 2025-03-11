#!/bin/bash

# Start agent installation for remote management. (e.g. MeshCentral, NinjaRMM, ConnectWise RMM, N-Able, etc...)


# End agent installation for remote management.

sleep 1s # Add little pauses for the machine to process all.

printf 'What should the hostname be? '
read -r new_hostname

sleep 1s # Add little pauses for the machine to process all.

echo "Setting new hostname..."

hostname "${new_hostname}"
echo "${new_hostname}" > /etc/hostname
sed -i "s/^127\.0\.1\.1.*/127.0.1.1       $new_hostname/" /etc/hosts

sleep 1s # Add little pauses for the machine to process all.

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
if [ -f /opt/ntos/tmp/debian-backports.pref ]; then
    mv /opt/ntos/tmp/debian-backports.pref /etc/apt/preferences.d/debian-backports.pref
fi

# Install the plymouth good looking theme.
unzip /opt/ntos/tmp/connect.zip -d /usr/share/plymouth/themes/connect

# Replace default desktop image.
cp /opt/ntos/desktop.png /usr/share/images/desktop-base/default

# Removing both xfce4-keyboard shortcuts to be sure.
echo 'Removing unwanted configurations and files if they exist...'

if [ -f /etc/xdg/autostart/light-locker.desktop ]; then
    rm /etc/xdg/autostart/light-locker.desktop # Prevent auto-locking due to autostart file.
fi

if [ -f /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ]; then
    rm /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml # Remove all system-wide keyboard shortcuts.
fi

if [ -f /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ]; then
    rm /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml # Remove all user-spaced keyboard shortcuts
fi

if [ -f /opt/ntos/tmp/setup-root.sh  ]; then
    rm /opt/ntos/tmp/setup-root.sh # Remove setup_root.sh script because no longer needed.
fi

echo -e '\nPending reboot, press any key to reboot.'
read -r
/sbin/reboot now

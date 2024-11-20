#!/bin/bash

currentUser=$(whoami)

#########################################
#                USER                   #
#########################################

printf 'Where is the remote webserver presenting the NTOS files? '
read -r web_address

printf 'What rdp file do you need for this configuration? (remove the .rdp from the name) '
read -r rdp_name

printf 'What should the hostname be? '
read -r new_hostname

echo -e '\nCustomizing user environment...'

curl "$web_address"/"${rdp_name}".rdp > /home/"${currentUser}"/Templates/remote-connection.rdp
curl "$web_address"/credcon.sh > /home/"${currentUser}"/Templates/credcon.sh

# Download the file to /home/${currentUser}/Templates (runs as the normal user)
wget "${web_address}"/Panel-Profile.tar.bz2 -P /home/"${currentUser}"/Templates
xfce4-panel-profiles load /home/"${currentUser}"/Templates/Panel-Profile.tar.bz2

# Set theme to Adwaita-Dark.
xfconf-query -c xsettings -p '/Net/ThemeName' -s 'Adwaita-dark'
xfconf-query -c xsettings -p '/Net/IconThemeName' -s 'Adwaita'
xfconf-query -c xsettings -p '/Gtk/CursorThemeName' -s 'Adwaita'

# Customize logout screen.
xfconf-query -c xfce4-session -np '/shutdown/ShowHibernate' -t 'bool' -s 'false'
xfconf-query -c xfce4-session -np '/shutdown/ShowSuspend' -t 'bool' -s 'false'
xfconf-query -c xfce4-session -np '/shutdown/ShowHybridSleep' -t 'bool' -s 'false'
xfconf-query -c xfce4-session -np '/shutdown/ShowSwitchUser' -t 'bool' -s 'false'
xfconf-query -c xfce4-session -np '/shutdown/LockScreen' -t 'bool' -s 'false'

# Limit workspaces (Like Virtual Desktops in Windows).
xfconf-query -c xfwm4 -p /general/workspace_count -s 1

# Desktop itself customization.
xfconf-query -c xfce4-desktop -np '/desktop-icons/style' -t 'int' -s '0'
xfconf-query -c xfce4-desktop -np '/desktop-menu/show' -t 'bool' -s 'false'
xfconf-query -c xfce4-desktop -np '/windowlist-menu/show-add-remove-workspaces' -t 'bool' -s 'false'

# Disable logout on screenlock and such things. (Unneeded without light-locker)
xfconf-query -c xfce4-power-manager -np '/xfce4-power-manager/lock-screen-suspend-hibernate' -t 'bool' -s 'false'
xfconf-query -c xfce4-power-manager -np '/xfce4-power-manager/logind-handle-lid-switch' -t 'bool' -s 'false'
#xfconf-query -c xfce4-power-manager -np '/xfce4-power-manager/presentation-mode' -t 'bool' -s 'true' # Presentation mode (The screen will not go into hibernation)

# Configure the span monitor option.
xfconf-query -c xfce4-panel -np '/panels/panel-1/span-monitors' -t 'bool' -s 'true'

#########################################
#                ROOT                   #
#########################################

echo -e '\nEscalating for remote management agent installation...'

# Use su to switch to root and run commands interactively
su -c "
# Start agent installation for remote management. (e.g. MeshCentral, NinjaRMM, ConnectWise RMM, etc...)



# End agent installation for remote management.

hostname $new_hostname &&
echo $new_hostname > /etc/hostname &&
sed -i 's/^127\.0\.1\.1.*/127.0.1.1       $new_hostname/' /etc/hosts &&
systemctl restart systemecsupportservice

# Check if the source file exists before copying
sleep 2s
if [ -f '/home/${currentUser}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml' ]; then
    echo 'Source xfce4-panel.xml found. Proceeding with copy.'

    # Copy xfce4-panel.xml to the system-wide config directory
    cp /home/${currentUser}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/ &&
    echo 'Successfully copied xfce4-panel.xml to /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/' &&

    # Lock the panel configuration
    sed -i 's|<channel name=\"xfce4-panel\" version=\"1.0\">|<channel name=\"xfce4-panel\" version=\"1.0\" locked=\"*\" unlocked=\"root\">|' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml &&
    echo 'Successfully applied the lock to xfce4-panel.xml'
    echo 'Error: Failed to modify xfce4-panel.xml with sed'
else
    echo 'Error: Source xfce4-panel.xml not found at /home/$currentUser/.config/xfce4/xfconfxfce-perchannel-xml/xfce4-panel.xml'
fi

mkdir -p /home/$currentUser/.config/autostart
cp /etc/xdg/autostart/light-locker.desktop /home/$currentUser/.config/autostart
echo 'Hidden=true' >> /home/$currentUser/.config/autostart/light-locker.desktop

echo -e '\nPending reboot, press any key to reboot.'
read doReboot
/sbin/reboot now
"
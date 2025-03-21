#!/bin/bash

# This should be executed by finish.sh as the user with given arguments.

web_address=$1
rdp_name=$2

# Downloading all needed files.

echo -e '\nDownloading needed files...'

curl -s "${web_address}"/rdp/"${rdp_name}".rdp > /opt/ntos/remote-connection.rdp                    # Download RDP file.
curl -s "${web_address}"/assets/gtk.css > /home/user/.config/gtk-3.0/gtk.css                        # GTK-CSS for makeup.

curl -s "${web_address}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh                              # Credcon utility/tool.
curl -s "${web_address}"/assets/bin/background-sync.sh > /opt/ntos/bin/background-sync.sh           # Background syncing tool.
curl -s "${web_address}"/assets/bin/install-firmware.sh > /opt/ntos/bin/install-firmware.sh         # Script utility to install extra firmware dependencies from kernel.org.
curl -s "${web_address}"/assets/bin/updater.sh > /opt/ntos/bin/updater.sh                           # NTOS update utility.

# Temporary script files for when root executes.
curl -s "${web_address}"/assets/tmp/setup-root.sh > /opt/ntos/tmp/setup-root.sh                 # Root setup script. Segregated to its own script.
curl -s "${web_address}"/assets/debian-backports.pref > /opt/ntos/tmp/debian-backports.pref     # Aptitude preference for freerdp repositories.
curl -s "${web_address}"/assets/VERSION > /opt/ntos/VERSION

# Bigger files what are not just text, therefor are downloaded with wget.
wget -q "${web_address}"/assets/panel-profile.tar.bz2 -P /opt/ntos                  # Panel profile.
wget -q "${web_address}"/assets/desktop.png -P /opt/ntos                            # Desktop background.
wget -q "${web_address}"/assets/third_party/connect.zip -P /opt/ntos/tmp            # Cool looking plymouth theme.

# Customize desktop environment.

echo "Applying panel profile..."
xfce4-panel-profiles load /opt/ntos/panel-profile.tar.bz2

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

# Configure the span monitor option.
xfconf-query -c xfce4-panel -np '/panels/panel-1/span-monitors' -t 'bool' -s 'true'

# Enable automounting
xfconf-query -c thunar-volman -np '/automount-drives/enabled' -t 'bool' -s 'true'
xfconf-query -c thunar-volman -np '/automount-media/enabled' -t 'bool' -s 'true'

# Set a nice looking background.
for x in $(xfconf-query -c xfce4-desktop -lv | grep last-image | awk '{print $1}')
do
    xfconf-query -c xfce4-desktop -p "$x" -s "/opt/ntos/desktop.png"
done

### Miscelaneous

# Append the export (for easy future management) to the bash profile so its an environment variable.
{ echo "export DISPLAY=:0"; 
  echo "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$UID/bus\""; 
  echo "export XDG_RUNTIME_DIR=\"unix:path=/run/user/$UID/bus\""; } >> /home/user/.bashrc

# Append origin to VERSION
sed -i "s|^ORIGIN=|ORIGIN=${web_address}|" /opt/ntos/VERSION

if [ -f /opt/ntos/tmp/setup-user.sh ]; then
    rm /opt/ntos/tmp/setup-user.sh # Remove setup_user.sh script because it is no longer needed.
fi
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
    service systemd-timesyncd restart;

    sed -i \"/^deb cdrom:/s/^/#/\" /etc/apt/sources.list &&
    echo \"deb http://ftp.de.debian.org/debian bookworm-backports main non-free non-free-firmware\" | tee /etc/apt/sources.list.d/debian-backports.list &&

    rm -rf /usr/share/doc/* /usr/share/locale/* /usr/share/man/* /usr/share/icons/*
    echo -e path-exclude=/usr/share/doc/*\\npath-exclude=/usr/share/man/*\\npath-exclude=/usr/share/locale/*\\npath-exclude=/usr/share/icons/* | tee /etc/dpkg/dpkg.cfg.d/excludes &&

    echo \"Removing oldest kernel (because a newer (backported) kernel will be installed)...\";
    OLD_KERNEL=\$(apt list linux-image* --installed 2>/dev/null | awk \"NR == 2\" | sed \"s/\\/.*//\")
    apt-get remove --purge -y \$OLD_KERNEL &&
    echo \$OLD_KERNEL;

    apt-get clean &&
    apt-get update &&

    apt-get install -y cups curl dbus-x11 network-manager-gnome plymouth-themes sane sane-utils system-config-printer \
        unzip xfce4 xfce4-goodies xfce4-panel-profiles xfce4-power-manager xsane yad &&
    apt-get clean -y &&
    apt-get autoremove -y &&

    apt-get install -y -t bookworm-backports \
        grub-common freerdp3-x11 firmware-intel-graphics firmware-realtek &&
    apt-get clean -y &&
    apt-get install -y -t bookworm-backports \
        linux-image-amd64 linux-headers-amd64 &&
    apt-get autoremove -y &&

    echo \"Unconfigured-NTOS\" > /etc/hostname &&
    sed -i \"s/127.0.1.1.*/127.0.1.1       Unconfigured-NTOS/\" /etc/hosts &&
    sed -i \"s/quiet/quiet loglevel=3 splash i915.modeset=1/\" /etc/default/grub &&
    sed -i \"s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/\" /etc/default/grub &&
    sed -i \"s/^#\(SystemMaxUse=\).*/\150M/\" /etc/systemd/journald.conf &&
    sed -i \"s/^#autologin-user=/autologin-user=user/\" /etc/lightdm/lightdm.conf &&

    mkdir -p /opt/ntos && chown user:user /opt/ntos &&
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

    # Retrieve data for installation.

    printf 'Where is the remote webserver presenting the NTOS files? '
    read -r web_address

    printf 'What rdp file do you need for this configuration? (remove the .rdp from the name)(case sensitive) '
    read -r rdp_name

    # Downloading all needed files.

    echo -e '\nDownloading needed files...'

    mkdir -p /home/user/.config/gtk-3.0/
    mkdir -p /opt/ntos/bin
    mkdir -p /opt/ntos/tmp

    curl -s "${web_address}"/rdp/"${rdp_name}".rdp > /opt/ntos/remote-connection.rdp                    # Download RDP file.
    curl -s "${web_address}"/assets/gtk.css > /home/user/.config/gtk-3.0/gtk.css                        # GTK-CSS for makeup.
    curl -s "${web_address}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh                              # Credcon utility/tool.
    curl -s "${web_address}"/assets/bin/background-sync.sh > /opt/ntos/bin/background-sync.sh           # Background syncing tool.
    curl -s "${web_address}"/assets/bin/install-firmware.sh > /opt/ntos/bin/install-firmware.sh         # Script utility to install extra firmware dependencies from kernel.org.

    # Temporary script files for when root executes.
    curl -s "${web_address}"/assets/bin/setup-root.sh > /opt/ntos/tmp/setup-root.sh                 # Root setup script. Segregated to its own script.
    curl -s "${web_address}"/assets/debian-backports.pref > /opt/ntos/tmp/debian-backports.pref     # Aptitude preference for freerdp repositories.

    wget -q "${web_address}"/assets/panel-profile.tar.bz2 -P /opt/ntos                  # Panel profile.
    wget -q "${web_address}"/assets/desktop.png -P /opt/ntos                            # Desktop background.
    wget -q "${web_address}"/assets/third_party/connect.zip -P /opt/ntos/tmp            # Cool looking plymouth theme.

    chmod +x /opt/ntos/bin/credcon.sh /opt/ntos/bin/background-sync.sh

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

    # Append the export (for easy future management) to the bash profile.
    echo "export DISPLAY=:0" >> /home/user/.bashrc
    echo "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$UID/bus\"" >> /home/user/.bashrc

    #########################################
    #                ROOT                   #
    #########################################

    echo -e '\nEscalating for remote management agent installation...'

    # Use su to switch to root and run commands interactively
    su root -c "bash /opt/ntos/tmp/setup-root.sh"
fi

#!/bin/bash

#########################################
#                ROOT                   #
#########################################

if [ ! -f '/etc/setup_done' ]; then

    su root -c 'sed -i "/^deb cdrom:/s/^/#/" /etc/apt/sources.list
    echo "deb http://ftp.de.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backport.list
    apt-get update
    apt-get install -y xfce4 xfce4-goodies xfce4-power-manager system-config-printer xfce4-panel-profiles xsane plymouth-themes dbus-x11 network-manager-gnome curl yad
    apt-get install -y -t bookworm-backports linux-image-amd64 linux-headers-amd64 freerdp3-x11 firmware-intel-graphics
    apt-get remove -y firefox-esr
    apt-get autoremove -y
    apt-get clean
    echo "NTOS-Setup" > /etc/hostname &
    sed -i "s/127.0.1.1.*/127.0.1.1       NTOS-Setup/" /etc/hosts &
    sed -i "s/quiet/quiet loglevel=3 splash i915.modeset=1/" /etc/default/grub &
    sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/" /etc/default/grub &
    sed -i "s/^#autologin-user=/autologin-user=user/" /etc/lightdm/lightdm.conf &
    sed -i "s/^#\\(SystemMaxUse=\\).*/\\150M/" /etc/systemd/journald.conf &
    mkdir /opt/ntos && chown user:user /opt/ntos &
    /sbin/grub-mkconfig -o /boot/grub/grub.cfg
    rm /etc/network/interfaces
    touch /etc/setup_done
    /sbin/reboot now
    '

fi

# User-username: user

#########################################
#                USER                   #
#########################################

if [ -f '/etc/setup_done' ]; then

    printf 'Where is the remote webserver presenting the NTOS files? '
    read -r web_address

    printf 'What rdp file do you need for this configuration? (remove the .rdp from the name)(case sensitive) '
    read -r rdp_name

    printf 'What should the hostname be? '
    read -r new_hostname

    echo -e '\nCustomizing user environment...'

    echo "Grabbing ${rdp_name}.rdp from NTOS server."
    curl -s "${web_address}"/rdp/"${rdp_name}".rdp > /opt/ntos/remote-connection.rdp

    echo "Grabbing Credcon from NTOS server."
    curl -s "${web_address}"/credcon/credcon.sh > /opt/ntos/credcon.sh
    chmod +x /opt/ntos/credcon.sh

    # Download the file to /opt/ntos (runs as the normal user)
    echo "Grabbing panel profile from NTOS server."
    wget -q "${web_address}"/assets/panel-profile.tar.bz2 -P /opt/ntos

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

    # Apply rounding GTK-3.0 CSS.
    mkdir -p /home/user/.config/gtk-3.0/
    curl -s "${web_address}"/assets/gtk.css > /home/user/.config/gtk-3.0/gtk.css
    xfce4-panel -r

    # Set a nice looking background.
    wget -q "${web_address}"/assets/desktop.png -P /opt/ntos
    for x in $(xfconf-query -c xfce4-desktop -lv | grep last-image | awk '{print $1}')
    do
        xfconf-query -c xfce4-desktop -p "$x" -s "/opt/ntos/desktop.png"
    done

    # Download the bg-sync.sh utility for syncing backgrounds
    curl -s "${web_address}"/assets/bg-sync.sh > /opt/ntos/bg-sync.sh

    # Append the export (for easy future management) to the bash profile.
    echo "export DISPLAY=:0" >> /home/user/.bashrc

    #########################################
    #                ROOT                   #
    #########################################

    echo -e '\nEscalating for remote management agent installation...'

    # Use su to switch to root and run commands interactively
    su root -c "
    # Start agent installation for remote management. (e.g. MeshCentral, NinjaRMM, ConnectWise RMM, N-Able, etc...)


    # End agent installation for remote management.

    hostname $new_hostname &&
    echo $new_hostname > /etc/hostname &&
    sed -i 's/^127\.0\.1\.1.*/127.0.1.1       $new_hostname/' /etc/hosts &&

    # Check if the source file exists before copying
    sleep 3s # Add some sleep for the machine to process everything.
    if [ -f '/home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml' ]; then
        echo 'Source xfce4-panel.xml found. Proceeding with copy.'

        # Copy xfce4-panel.xml to the system-wide config directory
        cp /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/ &&
        echo 'Successfully copied xfce4-panel.xml to /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/' &&

        # Lock the panel configuration
        sed -i 's|<channel name=\"xfce4-panel\" version=\"1.0\">|<channel name=\"xfce4-panel\" version=\"1.0\" locked=\"*\" unlocked=\"root\">|' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml &&
        echo 'Successfully applied the lock to xfce4-panel.xml'
    else
        echo 'Error: Source xfce4-panel.xml not found at /home/user/.config/xfce4/xfconfxfce-perchannel-xml/xfce4-panel.xml'
    fi

    # Removing both xfce4-keyboard shortcuts to be sure.
    echo 'Removing keyboard shortcuts'
    rm /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    rm /home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

    rm /etc/xdg/autostart/light-locker.desktop

    rm /etc/setup_done

    echo -e '\nPending reboot, press any key to reboot.'
    read doReboot
    /sbin/reboot now
    "
fi

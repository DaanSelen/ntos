#!/bin/bash
# Script to apply changes from version 1.1 to 1.1.1

version_file="/opt/ntos/VERSION"
# shellcheck source=/opt/ntos/VERSION
source "${version_file}"

# Downloading new files.
echo "Downloading new files..."

mkdir -p /home/user/.local/share/xfce4/helpers
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-FileManager.desktop > /home/user/.local/share/xfce4/helpers/blocked-FileManager.desktop
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-MailReader.desktop > /home/user/.local/share/xfce4/helpers/blocked-MailReader.desktop
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-TermEmu.desktop > /home/user/.local/share/xfce4/helpers/blocked-TermEmu.desktop
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-WebBrowser.desktop > /home/user/.local/share/xfce4/helpers/blocked-WebBrowser.desktop

curl -s "${ORIGIN}"/assets/mime-blocks/helpers.rc > /home/user/.config/xfce4/helpers.rc

curl -s "${ORIGIN}"/assets/debian-backports.pref > /opt/ntos/tmp/debian-backports.pref

# Remaining tasks
echo "Applying change..."

su root -c 'ln -sf /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml /opt/ntos/xfce4-panel.xml \
    && mv /opt/ntos/tmp/debian-backports.pref /etc/apt/preferences.d/debian-backports.pref \
    && chmod -R 755 /opt/ntos \
    && chown -R user:user /opt/ntos'

# Cleanup

[[ -f /opt/ntos/bin/intel-workaround.sh ]] && rm /opt/ntos/bin/intel-workaround.sh
[[ -f /opt/ntos/intel-workaround.service ]] && rm /opt/ntos/intel-workaround.service
[[ -f /etc/systemd/system/intel-workaround.service ]] && rm /etc/systemd/system/intel-workaround.service

sed -i '/^CUSTOM=/d' "$version_file"

# Standard version bumping
sed -i 's/^VERSION=1\.1$/VERSION=1.1.1/' "$version_file"
# Script to apply changes from version 1.1 to 1.1.1.

version_file="/opt/ntos/VERSION"
source $version_file

# Downloading new files.
echo "Downloading new files..."

curl -s "${ORIGIN}"/assets/mime-blocks/blocked-FileManager.desktop > /home/user/.local/share/xfce4/helpers/blocked-FileManager.desktop
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-MailReader.desktop > /home/user/.local/share/xfce4/helpers/blocked-MailReader.desktop
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-TermEmu.desktop > /home/user/.local/share/xfce4/helpers/blocked-TermEmu.desktop
curl -s "${ORIGIN}"/assets/mime-blocks/blocked-WebBrowser.desktop > /home/user/.local/share/xfce4/helpers/blocked-WebBrowser.desktop

curl -s "${ORIGIN}"/assets/mime-blocks/helpers.rc > /home/user/.config/xfce4/helpers.rc

curl -s "${ORIGIN}"/assets/debian-backports.pref > /opt/ntos/tmp/debian-backports.pref

# Remaining tasks
echo "Applying change..."

ln -sf /opt/ntos/xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
mv /opt/ntos/tmp/debian-backports.pref /etc/apt/preferences.d/debian-backports.pref

# Cleanup

[[ -f /opt/ntos/bin/intel-workaround.sh ]] && rm /opt/ntos/bin/intel-workaround.sh
[[ -f /opt/ntos/intel-workaround.service ]] && rm /opt/ntos/intel-workaround.service
[[ -f /etc/systemd/system/intel-workaround.service ]] && rm /etc/systemd/system/intel-workaround.service

# Standard version bumping
sed -i 's/"VERSION=1.1"/"VERSION=1.1.1"/' $version_file
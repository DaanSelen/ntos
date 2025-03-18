#!/bin/bash

# User-username: user

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
#!/bin/bash
# Script to apply changes from version 1.1.1 to 1.1.2

# Adding the contrib to the apt sources
sed -i '/^deb .*bookworm-backports/ s/\bmain\b/& contrib/' /etc/apt/sources.list.d/debian-backports.list

# Fetching new Credcon code.
curl https://ntos.systemec.nl/credcon/credcon.sh
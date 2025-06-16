#!/bin/bash
# Script to apply changes from version 1.1.1 to 1.1.2

version_file="/opt/ntos/VERSION"
# shellcheck source=/opt/ntos/VERSION
source "${version_file}"

# Adding the contrib to the apt sources
sed -i '/^deb .*bookworm-backports/ {/contrib/! s/\bmain\b/& contrib/}' /etc/apt/sources.list.d/debian-backports.list

# Fetching new Credcon code.
curl -s "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh

sed -i 's/^VERSION=1\.1\.1$/VERSION=1.1.2/' "$version_file"
#!/bin/bash

# Setting environment variables for operation.
source /opt/ntos/VERSION
local_version=$VERSION
remote_version=$(curl "${ORIGIN}"/VERSION)

# Grabbing the newest version of updater.


# Grabbing the newest version of Credcon.

echo "$remote_version"
echo "$local_version"

#curl "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh

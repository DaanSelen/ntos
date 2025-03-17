#!/bin/bash

# Setting environment variables for operation.

source /opt/ntos/VERSION

# Grabbing the newest version of Credcon.

remote_version=$(curl https://"${ORIGIN}/VERSION")
echo "$remote_version"

curl "${ORIGIN}"/credcon/credcon.sh > /opt/ntos/bin/credcon.sh
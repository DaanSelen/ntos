#!/bin/bash

# This script cleans up certain tmp directories to have more space in the moment.
# This can be handy for certain upgrades or actions.

# Example usage:
# su -c "/bin/bash /opt/ntos/bin/cleanup-env.sh"

rm -rf /tmp/*
rm -rf /var/cache/*
rm -rf /var/tmp/*
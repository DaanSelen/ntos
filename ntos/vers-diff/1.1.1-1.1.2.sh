#!/bin/bash
# Script to apply changes from version 1.1.1 to 1.1.2

sed -i '/^deb .*bookworm-backports/ s/\bmain\b/& contrib/' /etc/apt/sources.list.d/debian-backports.list
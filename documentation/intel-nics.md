# Intel NIC bug:

Fix: Add 
```
pcie_port_pm=off pcie_aspm.policy=performance
```
to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`. Then `update-grub2`. Reboot.

Source: https://www.reddit.com/r/buildapc/comments/xypn1m/network_card_intel_ethernet_controller_i225v_igc
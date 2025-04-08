# Intel NIC bug:

The Intel I226-V and I225-V series do have issues with this software from my own testing. No guaranteerd fix is found, possible fixes are below.

Fix: Add 
```
pcie_port_pm=off pcie_aspm.policy=performance
```
to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`. Then `update-grub2`. Reboot.

Source: https://www.reddit.com/r/buildapc/comments/xypn1m/network_card_intel_ethernet_controller_i225v_igc

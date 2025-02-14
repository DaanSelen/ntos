# Enabling Bluetooth Dongle Support on NTOS

## Overview
By default, NTOS does not support Bluetooth dongles out of the box. However, you can enable Bluetooth functionality with a simple package installation.

## Installation Steps
To enable support for Bluetooth dongles, install the required packages by running the following command:

```sh
apt install blueman bluez-firmware
```

### Explanation of Packages:
- **blueman**: A GTK-based Bluetooth manager that provides a user-friendly interface.
- **bluez-firmware**: Contains firmware files required for certain Bluetooth chipsets.

## Verifying the Installation
After installation, restart your Bluetooth service:

```sh
systemctl restart bluetooth
```

Check if the Bluetooth service is active:

```sh
status bluetooth
```

If your Bluetooth dongle is recognized, you can now use it to connect to Bluetooth devices.

## Troubleshooting
If the dongle is not detected, try the following:
- Unplug and replug the dongle.
- Run `lsusb` to check if the device is recognized.
- Use `bluetoothctl` to manually scan for devices.

## Conclusion
Although NTOS does not natively support Bluetooth dongles, enabling support is straightforward using `install blueman bluez-firmware`. After installation, service restart and a complete reboot (for the UI).
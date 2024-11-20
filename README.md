# Glossary (README.md)

Nerthus Thin Operating System (NTOS).<br>
I am happy I am finally able to present something I am actually very fond of, this project.<br>
I've tried to make this environment as fool-proof as possible so that non-technical people can work with this. I always appreciate feedback.<br>

## How to install:

The following section explains how to apply this.

### Prerequisites:
- A configured remote management system, such as MeshCentral (the installation of such a system is beyond the scope of NTOS).<br>
Such a remote management system often provides a way to install an agent. To incorporate this into the NTOS installation do:<br>
`Paste your installation commands into ./configs/<your-configuration>/finish.sh at line 64 to 66.`

    > If you do not configure a remote management system, then your system will be hard to debug or trouble-shoot (because of the fool-proof nature).<br>
    > Personally I've used MeshCentral which is free and works great!

- A Debian installation medium, such as an USB-stick with Debian net(work)-inst(allation) or the CD/DVD media flashed onto it. (For flashing see: [rufus](https://rufus.ie/) / [Balena Etcher](https://www.balena.io/etcher))<br>

### How to setup a webserver with NTOS files:

1.  To set everything up, execute the `setup.sh` bash script and answer its questions.<br>
    Once that's done, you can verify that with (configure to your own situation):<br>
    `curl http://localhost/configs/minimal/preseed.cfg`.<br>
    This should output the Debian preseed for the minimal configuration.<br>

### How to install a client.

1.  To kick-off the installation, insert your USB (or other medium) into your to-be installed system.<br>
    Just like a normal Debian installation boot off of the USB-medium. Then instead of entering the (graphical) install, go to `Advanced settings -> (graphical) Automated install.`<br>
    This will load basic modules from the installation media, and load them. These include but are not limited to network connectivity (to connect to the webserver presenting NTOS-files).<br>
    
    > For an example see [preseed-screen](./assets/images/debian12-preseed-screen.png).<br>

2.  Refering to the webserver endpoints below - enter the IP-address or hostname of the webserver followed by `/configs/<desired-config>/preseed.cfg`. By default the minimal configuration is available.<br>
    This makes the [Debian-installer](https://www.debian.org/devel/debian-installer/) use the preseed configuration for its installation.<br>
    The only manual input needed for installation is the partitioning, this is because this project has been made for a machine with 4GB total storage.<br>
    This means, if you have more than let's say 6GB total storage, then you can choose the Guided Partitioning (expert users can make something themselves).<br>

## Webserver endpoint structure:

The Bash `setup.sh`-script copies the needed files to the specificied location on the system, preferably a webserver root.

The following endpoints are available by default. This is needed for the new machine to set itself up.

```shell
/assets/Panel-Profile.tar.bz2   # XFCE4 Panel profile.
/credcon/credcon.sh             # Bash script for asking user credentials (for the RDP connection).
/configs/minimal/preseed.cfg    # The Debian preseed file.
/configs/minimal/finish.sh      # The Bash script that applies all settings.
/rdp/<your-templates>           # Directory endpoint for premade '.rdp' files
```

The above `/rdp` endpoint requires you to place premade `.rdp` files in the directory before running `setup.sh`.<br>
Then the finish script will ask for which one to pick.
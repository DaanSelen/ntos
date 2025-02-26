> [!NOTE]
> *If you experience issues or have suggestions, submit an issue! https://github.com/DaanSelen/ntos/issues I'll respond ASAP!*

# Glossary (README.md)

Nerthus Thin Operating System (NTOS).<br>
What is it? What problem does it solve?<br>
NTOS tries to solve the problem where enterprise-grade ThinClient operating systems cost a lot of money for relatively less features (in my opinion).<br>

This is where NTOS comes in: - it is based on Debian for stability and security - it can run on as small of a harddrive as 4GB with 2GB RAM (tested) - and it is very minimal.<br>
It (NTOS) specifically uses a Debian installation with a customized Desktop Environment (DE) (XFCE4) to minimize the points of "trouble" a user can cause.<br>

It offers a way to connect to cloud environments (currently only RDP-based) in a easy and straight-to-the-point method using the Credcon (Bash script) 😁.<br>

I added ways to set-up a server for installation (perhaps I can add PXE in the future). And a guide to get started! Feel free to open an issue or email me.<br>

# How to Install:

The following section explains how to apply this.<br>
I also made a YouTube video [here](https://www.youtube.com/watch?v=IZEBjlq8x00):

### Prerequisites:
- A configured remote management system, such as MeshCentral (the installation of such a system is beyond the scope of NTOS).<br>
Such a remote management system often provides a way to install an agent. To incorporate this into the NTOS installation do:<br>
Paste your installation commands into the root part, for example: `./configs/minimal/finish.sh at line 84 to 87`.

    > If you do not configure a remote management system, then your system will be hard to debug or trouble-shoot (because of the fool-proof nature).<br>
    > Personally I've used MeshCentral which is free and works great! Link is [here](https://github.com/Ylianst/MeshCentral)

- A Debian installation medium, such as an USB-stick with Debian net(work)-inst(allation) or the CD/DVD media flashed onto it. (For flashing see: [rufus](https://rufus.ie/) / [Balena Etcher](https://www.balena.io/etcher))<br>

- Networking connectivity. (DHCP is easiest and fastest)

### How to Install a NTOS-Server using a webserver:

1.  To set everything up, execute the `install.sh` bash script and answer its questions.<br>
    Once that's done, you can verify that with (configure to your own situation):<br>
    `curl http://localhost/configs/minimal/preseed.cfg`. Look at the webserver structure below for more info.<br>
    This should output the Debian preseed for the minimal configuration.<br>

### How to Install a NTOS-Client:

1.  To install an NTOS-Client machine, first setup the NTOS-Server and make sure its reachable from the candidate machine.<br>
    After that boot from the Debian ISO image and select from the advanced options the (Graphical) Automated Install.<br>
    Now wait for it to get ready, and after that enter the address of NTOS-Server with the path of the configuration (look at the webserver structure below for reference).<br>
    The partitioning has to be done manually, if you have around 4GB you need to do some manual configurations but if you have more, you can safely do a guided install.<br>
    Now wait for the system to fully install itself, you'll know its done when you see the default XFCE4 Desktop Environment (DE).<br>

2.  Open a Terminal window (you can select the one from the bottom dock). And execute the `finish.sh` script of your configuration.<br>
    Normally done through `bash <(curl <your-NTOS-Server-address>/configs/<your-config>/finish.sh)` (You might need to install curl first with apt).<br>
    Once you have done the previous bash command answer the questions given, and all should be configured.

### Setting a Custom Boot-up (Plymouth) Animation:

To finish this all up, set a nice looking boot-up animation. My personal preference is to choose a theme from: [adi1090x/plymouth-themes](https://github.com/adi1090x/plymouth-themes).<br>
To set this up correctly follow the configuration for you specific hardware vendors, see the resources below:

- [Debian Plymouth Wiki](https://wiki.debian.org/plymouth)
- [Arch Plymouth Wiki (for information)](https://wiki.archlinux.org/title/Plymouth). This is listed here for information. NTOS is based on Debian.
- [Third-party Guide to set Plymouth up](https://donjajo.com/plymouth-installing-configuring-boot-screen-debian/)

If there are more cool animations. Let me know.

# How to Debug?

### RDP-related

If you are encountering issues with - most likely connecting the actual RDP-session. Follow these steps!<br>
Make sure you have exported the correct DISPLAY environment variable. Usually this is `DESKTOP=:0`.<br>
The way I do this - is in MeshCentral I enter the `Terminal` tab and enter `export DISPLAY=:0` as the user (latest `finish.sh` scripts append this to `~/.bashrc`).<br>

> This makes sure all graphical apps pop-up on the actual monitor!

Then if you want to debug `credcon.sh` with logs do the following:

```shell
bash /opt/ntos/credcon.sh
```

This will print the output to the current terminal, while keeping the GUI/Dialogue boxes on the monitor!

Example output:
```text
user@NTOS:/opt/ntos# bash credcon.sh 
Starting loading bar
# 1%
# 2%
# 3%
# 4%
[16:39:02:892] [8315:8327] [ERROR][com.freerdp.core] - freerdp_tcp_connect:freerdp_set_last_error_ex ERRCONNECT_DNS_NAME_NOT_FOUND [0x00020005]
# 5%
[16:39:02:946] [8315:8327] [ERROR][com.freerdp.core] - rdg_establish_data_connection:freerdp_set_last_error_ex ERRCONNECT_ACCESS_DENIED [0x00020016]
[16:39:02:891] [8315:8327] [INFO][com.freerdp.core.nego] - Detecting if host can be reached locally. - This might take some time.
[16:39:02:891] [8315:8327] [INFO][com.freerdp.core.nego] - To disable auto detection use /gateway-usage-method:direct
[16:39:02:891] [8315:8327] [INFO][com.freerdp.core.nego] - Detecting if host can be reached locally. - This might take some time.
[16:39:02:891] [8315:8327] [INFO][com.freerdp.core.nego] - To disable auto detection use /gateway-usage-method:direct
# 6%
# 7%
# 8%
# 9%
# 10%
xfreerdp terminated early (less than '30' seconds).
# 11%
...counting up (omitted because it takes up more space than needed.)
# 23%
```

The above example shows a `ACCESS_DENIED` error. 

### Desktop Environment related:

When encountering an off-sync background image, which can happen when you install the system fully with one monitor and connect a second one after.<br>
Do the following:
```shell
su user -c "bash /opt/ntos/bg-sync.sh"
```
This will sync the image present at /opt/ntos/desktop.png to all connected monitors.

# Images:

<img src="./assets/images/preseed.jpeg" alt="Preseed-screen" width="600"/><br>
<img src="./assets/images/partitioner.jpeg" alt="Partitioner screen" width="600"/><br>
<img src="./assets/images/firstboot.jpeg" alt="First-boot desktop" width="600"/><br>
<img src="./assets/images/finish_sh.jpeg" alt="Executing finish.sh" width="600"/><br>

## Webserver Endpoint-structure:

The Bash `install.sh`-scripts are there for copying the needed files to the specificied location on the system, preferably from a webserver root into the /opt/ntos directory.

The following endpoints are available by default after installing using `install.sh` (assuming success). This is needed for the new machine to set itself up.

```shell
--- Complimentary Assets
/assets/bg-sync.sh              # This bash script can sync the background images. Sometimes images are off-sync when connecting a second monitor.
/assets/desktop.png 	        # This file will be used as the background for the installed device. Replacing must be done by exactly coping the name + filename extension.
/aseets/gtk.css                 # This file applies some styling to make the UI look more modern and appealing.
/assets/panel-profile.tar.bz2   # XFCE4 Panel profile.

--- Credcon
/credcon/credcon.sh             # Bash script for asking user credentials (for the RDP connection).

--- Configs
/configs/minimal/preseed.cfg    # The Debian preseed file for the minimal configuration (~4GB).
/configs/default/preseed.cfg    # The default Debian preseed file.
/configs/minimal/finish.sh      # The Bash script that applies all settings with a modification for support on small drives.
/configs/default/finish.sh      # The default bash script.

--- RDP Directory
/rdp/<your-rdp-templates>       # Directory endpoint for premade '.rdp' files (for example /rdp/demo.rdp). You NEED to populate this yourself.

```

The above `/rdp` endpoint requires you to place premade `.rdp` files in the directory before running `setup.sh`.<br>
Then the finish script will ask for which one to pick.

# Epilogue

I am happy I am finally able to present something I am actually very fond of, this project.<br>
I've tried to make this environment as fool-proof as possible so that non-technical people can work with this. I always appreciate feedback.<br>
Thanks<br>

### How to install a client.

1.  To kick-off the installation, insert your USB (or other medium) into your to-be installed system.<br>
    Just like a normal Debian installation boot off of the USB-medium. Then instead of entering the (graphical) install, go to `Advanced settings -> (graphical) Automated install.`<br>
    This will load basic modules from the installation media, and load them. These include but are not limited to network connectivity (to connect to the webserver presenting NTOS-files).<br>
    
    > For an example see [preseed-screen](../assets/images/debian12-preseed-screen.png).<br>

2.  Refering to the webserver endpoints below - enter the IP-address or hostname of the webserver (with the port) followed by `/configs/<desired-config>/preseed.cfg`. By default the minimal and default configurations are available.<br>
    This makes the [Debian-installer](https://www.debian.org/devel/debian-installer/) use the preseed configuration for its installation.<br>
    I advice using the default configuration if you have more than 4GB storage, and the minimal if you have 4 GB or slightly less. There is no difference in what these configs achieve but a matter of how.<br>
    The minimal preseed installs the base system and expects you to run the `finish.sh` twice, one time to set up the Desktop Environment (DE) and another time to customize that DE.<br>
    The default installation does this all in one go (installing the DE from the preseed), so therefor you only need to run `finish.sh` once. The way this is done is by moving around the `late_command` to the `finish.sh` part.<br>

    The only manual input needed for installation is the partitioning, this is because this project has been made for a machine with 4GB total storage.<br>

    > If you actually have only 4GB, create a single parition that is mounted to `/` and use the minimal configuration, the end-result if the same for both.<br>

    This means, if you have more than let's say 6GB total storage, then you can choose the Guided Partitioning (expert users can make something themselves).<br>

3.  Now the machine will install itself using the selected configuration from ./ntos/configs (if you selected it correctly).<br>
    Just wait a while, the older the machine the slowed it will be. Once the installation is complete the machine will restart itself as per instruction of the preseed. <br>

4. Once the machine has succesfully booted into the Desktop Environment (DE) you have chosen (the default is XFCE4) open a terminal and enter:<br>
    `bash <(curl <your-ntos-server-ip/hostname:port>/configs/<desired-config>)`<br>
    This will initiate the 'finisher'-script, after which the install should be complete.

    > For examples see the image examples or the [images-directory](../assets/images)

5. Enjoy! Linux is so much fun to use. 😉
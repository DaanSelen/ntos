# Microsoft Teams

# TO BE REVISED.

Since Microsoft Teams is not natively running on Linux we are going to use the chromium webapp.<br>
Install Chromium onto your NTOS machine via your preferred method.

Then install it as a webapp through the Chromium settings.<br>
After that apply the panel profile called `panel-profile-teams.tar.bz2` with `xfce4-panel-profiles load <the_location>`.<br>

Important here is that you make sure the app-id is correct in the launcher, this should be in:<br>
```
/home/user/.config/chromium/Default/Web\ Applications/Manifest\ Resources
```
For example: `cifhbcnohmdccbgoicgdjpfamggdegmo`. And to change this you might have to unlock the NTOS panel profile.<br>
This can be done by removed (or preferably commenting) the "locked" part of: `/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml`. See an example below.
```
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-panel" version="1.0"><? locked="*" unlocked="root"?>
...
```
# My awesomewm config

## Requirements

- feh
- pass
- passdmenu
- emojimenu
- dmenu
- nerd-fonts (At least Terminess)
- st (suckless terminal)
- lua-socket (for weather widget)

## Installation

This setup should be available as part of my dotfiles (which you are looking
at right now).

## Mail widget setup

Create a config file called `~/.config/imap.cfg`. It should contain the following:

```inifile
[auth]
username=<username for imap>
password=<password for imap>

[server]
host=<imap host>
port=993
```

## Weather widget setup

Open `rc.lua` and look for the weather-widget in the wibar-section (just
grep/look for weather. Change the city to what you want (Default is Delft, where
I'm from)

# AwesomeWM config

Personal AwesomeWM configuration for a 3-monitor AMD desktop.
Based on the [awesome-copycats](https://github.com/lcpz/awesome-copycats) powerarrow theme,
with heavily modified widgets and a [wallust](https://codeberg.org/explosion-mental/wallust)
color scheme integration.

## Installation

```bash
git clone --recurse-submodules <this-repo> ~/.config/awesome
cd ~/.config/awesome
bash install.sh
```

The script supports **Arch Linux**, **Debian**, **Ubuntu/Mint**, **FreeBSD**, and **OpenBSD**.
Pass `--dry-run` to preview what it would do without making changes.

### What the script does

- Initialises git submodules (`lain`, `freedesktop`, `awesome-wm-widgets`)
- Installs all required system packages via the native package manager
- On Arch: installs AUR packages (`brave-bin`, `wallust`) and bootstraps `yay` if needed
- Installs the pacman hook that triggers the update widget after package operations (Arch only)
- Enables the MPD user service
- Creates a placeholder `~/.cache/wal/awesome-colors.lua` so awesome starts without wallust

### Manual steps after install

1. **Font** — Install [BerkeleyMono Nerd Font](https://berkeleygraphics.com/typefaces/berkeley-mono/)
   (commercial). Any other Nerd Font monospace works as a substitute — change `theme.font`
   in `themes/powerarrow/theme.lua`.

2. **MPD** — Edit `~/.config/mpd/mpd.conf` with your music directory and start the daemon.

3. **Weather widget** — Store your [weatherapi.com](https://www.weatherapi.com/) API key:
   ```bash
   pass insert api/weatherapi.com/key
   ```

4. **Wallpaper / colors** — Run wallust on a wallpaper to generate the color scheme:
   ```bash
   wallust run /path/to/wallpaper.jpg
   ```
   Or use the keybindings once inside AwesomeWM: `Ctrl+Alt+W` (random), `Ctrl+Alt+Shift+W` (reload).

## Key dependencies

| Package | Purpose |
|---|---|
| `awesome` | Window manager |
| `picom` | Compositor |
| `kitty` | Terminal |
| `mpd` + `mpc` + `ncmpcpp` | Music |
| `rofi` + `dmenu` | Launchers |
| `pactl` (`libpulse`) | Volume control |
| `lua-lgi` | In-memory cover art decode (GdkPixbuf → Cairo) |
| `pacman-contrib` | `checkupdates` for the update widget (Arch) |
| `wallust` | Pywal-compatible color scheme generator (AUR) |
| `brave-bin` | Default browser (AUR) |
| BerkeleyMono Nerd Font | UI font (commercial, manual install) |

## Structure

```
rc.lua                        # Keybindings, rules, autostart, tags
themes/powerarrow/theme.lua   # Wibar layout, all widgets, colors, fonts
pacmanwidget/                 # Repo + AUR update count widget
lain/                         # Widget library submodule
freedesktop/                  # Right-click app menu submodule
awesome-wm-widgets/           # Weather widget submodule
picom.conf                    # Compositor config
install.sh                    # Dependency installer
```

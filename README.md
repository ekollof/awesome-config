# AwesomeWM Configuration

Personal AwesomeWM 4.x configuration for a 3-monitor desktop.
Based on the [awesome-copycats](https://github.com/lcpz/awesome-copycats) powerarrow theme,
heavily extended with custom widgets, multi-distro support, and quality-of-life improvements.

## Screenshots

> Theme adapts dynamically to the current wallpaper via [wallust](https://codeberg.org/explosion-mental/wallust).

## System

| | |
|---|---|
| **WM** | AwesomeWM 4.x |
| **Theme** | powerarrow (default), copland |
| **Terminal** | kitty |
| **Compositor** | picom |
| **Font** | BerkeleyMono Nerd Font |
| **Colors** | wallust (pywal-compatible, auto-generated from wallpaper) |
| **Theme picker** | `Super+Shift+T` — switch theme and restart AwesomeWM (choice persisted) |
| **Monitors** | DisplayPort-0 2560×1080 (primary), DisplayPort-1 1920×1080, HDMI-A-0 1920×1080 |

## Installation

```bash
git clone --recurse-submodules <this repo> ~/.config/awesome
bash ~/.config/awesome/install.sh
```

The installer supports **Arch, Debian, Ubuntu/Mint, Fedora, Alpine, FreeBSD, and OpenBSD**.
It installs all required packages, enables RPM Fusion on Fedora, builds i3lock-color from
source on Debian/Ubuntu/Fedora, and installs the pacman update hook on Arch.

## Features

### Wibar
 
A single 32px top bar on each monitor with powerline arrow separators.
Segment colors are drawn from the active wallust palette so the bar always matches the wallpaper.
 
**Left → Right:**
 
| Widget | Description |
|---|---|
| Taglist | 9 tags (➊–➒); click to switch, scroll to cycle, `Super+click` to move client |
| Promptbox | Lua/run prompt (`Alt+x`) |
| Tasklist | Focused window title |
| *(spacer)* | |
| Update counter | Pending package count (`N` or `N+M` repo+AUR); hover for full package list; auto-updates on every package transaction (pacman hook) |
| MPD | Artist · Title; click prev/toggle/next/stop; scroll to adjust volume |
| System Monitor | Combined CPU%, RAM (MB), and Temp (°C); **hover for dashboard** |
| Weather | Current conditions + icon; key stored in `pass`; hover for forecast |
| Battery | Charge % + status icon; hidden automatically on systems with no battery |
| Volume | Dynamic icon (mute/low/normal) + bar; scroll ±2%, click to toggle mute |
| Network | rx/tx rates; hover for per-interface popup |
| Uptime | Time since boot (e.g. `7h 45m`) |
| Clock | Weekday + date + time; click for calendar popup |
| Layout box | Active layout icon; click/scroll to cycle layouts |
| Systray | Integrated into powerline wibar with a dedicated background segment for visibility; `Super+-` to toggle |
 
### Dashboard
 
Hovering over the **System Monitor** segment reveals a rich visual dashboard featuring:
- **CPU**: Real-time load graph and usage percentage.
- **Memory**: Usage bar, history graph, and MB breakdown.
- **Temperature**: Heat trend graph and current degree status.
- **Disk I/O**: Dedicated Read/Write throughput graphs (Linux only).
 
### Tags & Layouts

9 tags per screen (➊–➒). Available layouts in cycle order:

`tile` → `floating` → `tile.left` → `tile.bottom` → `tile.top` → `max` → `magnifier`

Dynamic tag management (lain): add (`Super+Shift+n`), rename (`Super+Ctrl+r`), delete (`Super+Shift+y`).

### Window Management

**Max layout minimization** — when the `max` layout is active, non-focused tiled clients are
automatically minimized and restored on focus, preventing compositor bleed-through.
User-minimized windows are unaffected.

**Alt-Tab LRU cycling** — `Alt+Tab` / `Alt+Shift+Tab` cycle through clients on the current tag
in last-used order, matching the behaviour of most desktop environments.

**Urgent notifications** — when any unfocused window raises the urgent flag (chat ping,
build finished, terminal bell, etc.) a naughty notification appears with the window title and icon.
`Super+u` jumps straight to the window.

**Window reset** — `Super+F5` atomically clears all stuck window states: maximized, fullscreen,
floating, ontop, sticky, minimized.

**Focus follows mouse** — sloppy focus; mouse entry activates without raising.

### Screen Locker

`Ctrl+Alt+L` locks the screen with i3lock-color using the current wallust wallpaper.
`xss-lock` triggers the same locker automatically on X screensaver idle timeout.
The locker shows a clock and ring indicator; all fonts are BerkeleyMono Nerd Font.

### Wallust Integration

Wallust generates `~/.cache/wal/awesome-colors.lua` from the current wallpaper.
AwesomeWM reads this at startup so every color — bar segments, borders, notifications — 
matches the wallpaper automatically.

```bash
wallpaper random    # pick random wallpaper, regenerate colors, restart AwesomeWM
wallpaper reload    # re-run wallust on current wallpaper, restart AwesomeWM
```

Keybindings: `Ctrl+Alt+W` (random), `Ctrl+Alt+Shift+W` (reload).

> **Note:** AwesomeWM inherits a stripped PATH from the X session and cannot see tools
> installed into `~/.cargo/bin`, `~/.local/share/mise`, etc. Wallust must be symlinked
> into `~/.local/bin` so AwesomeWM can find it:
> ```bash
> ln -sf ~/.cargo/bin/wallust ~/.local/bin/wallust
> ```
> Without this, `Ctrl+Alt+W`/`Ctrl+Alt+Shift+W` will set the wallpaper via feh but
> the color palette will not update and AwesomeWM will not restart.

### Volume

Volume is controlled via `pactl` (PulseAudio/PipeWire). An in-place naughty notification
shows a `█░` progress bar on every change so you can see the level without looking at the bar.

### Update Widget

`updatewidget/` detects the running distro and selects the appropriate backend:

| Distro | Method |
|---|---|
| Arch | `checkupdates` (repo) + `yay` (AUR) |
| Debian / Ubuntu / Mint | `apt-get -s upgrade` (phasing-aware — excludes held-back packages) |

Polls every 5 minutes. On Arch, the pacman alpm hook triggers an immediate refresh after
any package transaction without waiting for the next poll.

## Keybindings

### Applications

| Keys | Action |
|---|---|
| `Super+Return` / `Super+t` / `Ctrl+Alt+t` | kitty terminal |
| `Super+w` / `Super+F1` / `Ctrl+Alt+f` | Brave browser |
| `Super+F8` / `Super+Shift+Return` / `Ctrl+Alt+b` | Thunar file manager |
| `Super+F10` / `Ctrl+Alt+s` | ncmpcpp |
| `Super+F11` | Rofi (fullscreen) |
| `Super+F12` | Rofi |
| `Super+v` / `Ctrl+Alt+u` | pavucontrol |
| `Super+F4` | GIMP |
| `Super+F6` | VLC |
| `Super+Escape` | xkill |
| `Ctrl+Alt+a` / `Alt+F3` | xfce4-appfinder |
| `Ctrl+Alt+m` | xfce4-settings-manager |
| `Ctrl+Shift+Escape` | xfce4-taskmanager |
| `F12` | xfce4-terminal (dropdown) |
| `Print` | scrot screenshot |
| `Ctrl+Print` | xfce4-screenshooter |
| `Alt+x` | Lua prompt |

### Window Management

| Keys | Action |
|---|---|
| `Super+j/k/h/l` | Focus client by direction |
| `Alt+j/k` | Focus next/previous client |
| `Alt+Tab` | Focus next client (LRU) |
| `Alt+Shift+Tab` | Focus previous client (LRU) |
| `Super+u` | Jump to urgent client |
| `Super+Shift+j/k` | Swap client with next/previous |
| `Super+Ctrl+Return` | Move client to master |
| `Super+Shift+Left/Right` | Move client to next/previous screen |
| `Super+f` | Toggle fullscreen |
| `Super+m` | Toggle maximized |
| `Super+n` | Minimize |
| `Super+Ctrl+n` | Restore last minimized |
| `Super+Shift+space` | Toggle floating |
| `Super+F5` | Reset all window states |
| `Super+q` | Close client |

### Tags

| Keys | Action |
|---|---|
| `Super+1–9` | Switch to tag |
| `Super+Shift+1–9` | Move client to tag |
| `Super+Ctrl+1–9` | Toggle tag display |
| `Super+Left/Right` | Previous/next tag |
| `Super+Tab` / `Super+Shift+Tab` | Cycle tags |
| `Super+Shift+n` | New tag |
| `Super+Ctrl+r` | Rename tag |
| `Super+Shift+y` | Delete tag |

### Layouts

| Keys | Action |
|---|---|
| `Super+space` | Next layout |
| `Alt+Shift+l/h` | Increase/decrease master width |
| `Super+Shift+h/l` | More/fewer master clients |
| `Super+Ctrl+h/l` | More/fewer columns |
| `Alt+Ctrl+j/h` | Increase/decrease useless gaps |

### Volume & Media

| Keys | Action |
|---|---|
| `XF86AudioRaiseVolume` | +1% |
| `XF86AudioLowerVolume` | -1% |
| `XF86AudioMute` | Toggle mute |
| `Ctrl+Shift+m` | Set to 100% |
| `Ctrl+Shift+0` | Set to 0% |
| `XF86AudioPlay` / `Ctrl+Shift+Up` | MPD toggle |
| `XF86AudioNext` / `Ctrl+Shift+Right` | MPD next |
| `XF86AudioPrev` / `Ctrl+Shift+Left` | MPD previous |
| `XF86AudioStop` / `Ctrl+Shift+Down` | MPD stop |
| `XF86MonBrightnessUp/Down` | Backlight ±10% |

### System

| Keys | Action |
|---|---|
| `Ctrl+Alt+L` | Lock screen |
| `Ctrl+Alt+W` | Random wallpaper |
| `Ctrl+Alt+Shift+W` | Reload wallpaper colors |
| `Ctrl+Alt+O` | Toggle picom compositor |
| `Super+b` | Toggle wibar |
| `Super+-` | Toggle systray |
| `Super+s` | Hotkeys cheatsheet |
| `Super+Shift+r` | Restart AwesomeWM |
| `Super+Ctrl+q` | Quit AwesomeWM |

## Dependencies

Core runtime dependencies installed by `install.sh`:

- `awesome`, `picom`, `kitty`
- `rofi`, `dmenu`
- `mpd`, `mpc`, `ncmpcpp`
- `thunar`, `xfce4-terminal`, `xfce4-taskmanager`, `xfce4-appfinder`, `xfce4-screenshooter`, `xfce4-settings`
- `alsa-utils`, `pavucontrol`, `pulseaudio`/`pipewire`
- `scrot`, `unclutter-xfixes`, `arandr`, `xss-lock`
- `pass`, `curl`
- `lua-lgi` (for cover art decoding)
- `i3lock-color` (built from source on Debian/Ubuntu/Fedora)
- `wallust` (AUR on Arch; manual install elsewhere)
- BerkeleyMono Nerd Font (commercial; install manually)

## Submodules

| Directory | Purpose |
|---|---|
| `lain/` | Widget library — MPD, memory, CPU, net, calendar, separators |
| `freedesktop/` | Right-click desktop app menu from `.desktop` files |
| `awesome-wm-widgets/` | Weather widget |

## File Structure

```
~/.config/awesome/
├── rc.lua                        # Main config
├── themes/<name>/theme.lua       # Wibar, widgets, colors (powerarrow, copland)
├── updatewidget/                 # Multi-distro update counter
├── widgets/
│   ├── sysmon.lua                # Consolidated CPU/Mem/Temp/Disk dashboard
│   ├── uptime.lua                # Portable uptime widget
│   ├── net.lua                   # Network traffic widget
│   ├── battery.lua               # Portable battery widget
│   └── mpd.lua                   # MPD player widget
├── scripts/
│   ├── lock.sh                   # i3lock-color screen locker
│   ├── build-i3lock-color.sh     # Build i3lock-color from source
│   └── picom-toggle.sh           # Toggle compositor
├── contrib/
│   ├── wallpaper.sh              # Wallpaper setter + wallust + AwesomeWM restart
│   └── wallust/
│       ├── wallust.toml          # Example wallust config (copy to ~/.config/wallust/)
│       └── templates/
│           ├── awesome-colors.lua  # Lua palette template (required)
│           ├── colors-rofi.rasi    # Rofi color theme
│           └── colors-kitty.conf   # Kitty terminal colors
├── picom.conf                    # Compositor config
├── install.sh                    # Dependency installer
├── lain/                         # Submodule
├── freedesktop/                  # Submodule
└── awesome-wm-widgets/           # Submodule
```

## contrib/

The `contrib/` directory contains example configurations and helper scripts that
are not required by AwesomeWM itself but are useful companions to this setup.
See [`contrib/README.md`](contrib/README.md) for setup instructions.

| File | Description |
|---|---|
| `contrib/wallpaper.sh` | Set a wallpaper, regenerate the wallust palette, and restart AwesomeWM in one command. Supports `random`, a specific path, or `reload` to reprocess the current wallpaper. |
| `contrib/wallust/wallust.toml` | Minimal wallust config with the templates this setup needs. Copy to `~/.config/wallust/wallust.toml`. |
| `contrib/wallust/templates/awesome-colors.lua` | Lua palette template consumed by `theme.lua`. Required for wallust integration. |
| `contrib/wallust/templates/colors-rofi.rasi` | Rofi color theme template. `@import` from your rofi config. |
| `contrib/wallust/templates/colors-kitty.conf` | Kitty terminal color template. `include` from `kitty.conf`. |

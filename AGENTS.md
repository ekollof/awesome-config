# AwesomeWM Configuration

Personal AwesomeWM configuration for a 3-monitor desktop (AMD Ryzen, no battery).
Based on the [awesome-copycats](https://github.com/lcpz/awesome-copycats) powerarrow theme.

## System

- **WM:** AwesomeWM 4.x
- **Theme:** powerarrow (modified) — `themes/powerarrow/`
- **Terminal:** kitty
- **Compositor:** picom (`picom.conf`)
- **Font:** BerkeleyMono Nerd Font
- **Color scheme:** [wallust](https://codeberg.org/explosion-mental/wallust) (pywal-compatible), colors loaded from `~/.cache/wal/awesome-colors.lua`

## Monitors

| Output | Resolution | Role |
|---|---|---|
| DisplayPort-0 | 2560×1080 | Primary (ultrawide) |
| DisplayPort-1 | 1920×1080 | Secondary |
| HDMI-A-0 | 1920×1080 | Tertiary |

## Key files

| File/Dir | Purpose |
|---|---|
| `rc.lua` | Main config — keybindings, rules, autostart, tags |
| `themes/powerarrow/theme.lua` | Wibar layout, all widgets, wallust colors, fonts |
| `pacmanwidget/` | Custom pacman/AUR update count widget |
| `scripts/picom-toggle.sh` | Toggle picom compositor (bound to Ctrl+Alt+O) |
| `picom.conf` | Picom compositor config |

## Submodules

| Directory | Upstream | Purpose |
|---|---|---|
| `lain/` | https://github.com/lcpz/lain | Widget library (MPD, mem, cpu, net, cal, separators) |
| `freedesktop/` | https://github.com/lcpz/awesome-freedesktop | Right-click app menu from .desktop files |
| `awesome-wm-widgets/` | https://github.com/streetturtle/awesome-wm-widgets | Weather widget (`weather-api-widget/` only used) |
| `pacmanwidget/` | https://github.com/raksooo/pacmanwidget | Base for the pacman update widget (heavily modified) |

## Wallust integration

Wallust writes `~/.cache/wal/awesome-colors.lua` from the template at
`~/.config/wallust/templates/awesome-colors.lua`. AwesomeWM reads this file
at startup. To apply a new wallpaper and reload colors:

```
wallpaper random      # picks random wallpaper, runs wallust, restarts awesome
wallpaper reload      # re-runs wallust on current wallpaper, restarts awesome
```

Keybindings: `Ctrl+Alt+W` (random), `Ctrl+Alt+Shift+W` (reload).

## Autostart

Autostart commands are read from `~/bin/autostart list` and fed through
`run_once()` in `rc.lua`. Edit `~/.config/autostart/*.desktop` files to
manage autostart apps. Do not edit `autostart` in this repo — that script
lives in `~/bin/`.

## Audio / Volume

Volume control uses `pactl` (PulseAudio/PipeWire). Keybindings on
XF86AudioRaiseVolume / XF86AudioLowerVolume / XF86AudioMute.

## MPD

Music served from NAS at `/net/192.168.178.39/storage/Music/`.
Cover art fetched via `mpc readpicture`. MPD widget shows artist/title,
supports prev/toggle/next/stop clicks and scroll-to-change-volume.

## Pacman hook

`/etc/pacman.d/hooks/pacmanWidget.hook` triggers `pacman_widget_hook()` (an
AwesomeWM global) after package operations to refresh the update count
without waiting for the next 5-minute poll.

## Agent guidelines

- **Do not** call `~/bin/autostart` directly — it spawns all autostart apps
  blindly. Use `~/bin/autostart list` to get the list and feed through `run_once()`.
- **Do not** use `os.execute()` in Lua — it blocks the main loop. Always use
  `awful.spawn.with_shell()` or `awful.spawn.easy_async_with_shell()`.
- **Wallpaper** uses `gears.wallpaper.fit` (not `maximized`) to preserve
  aspect ratio on the ultrawide monitor.
- **Widget instances** must be created per-screen — a widget can only have
  one parent in AwesomeWM.
- **Debug logging** should use `io.open` file-based logging, not
  `awesome-client`, since async callbacks make client-based debugging unreliable.
- CPU temperature is at `/sys/class/hwmon/hwmon4/temp1_input` (zenpower, millidegrees C).
- No battery on this system — battery widget is conditionally hidden via
  `has_battery` check on `/sys/class/power_supply/BAT*`.

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
| `updatewidget/` | Multi-distro update count widget (apt/pacman/yay) |
| `scripts/lock.sh` | Screen locker — reads wallust wallpaper, runs i3lock-color |
| `scripts/build-i3lock-color.sh` | Build i3lock-color from source (Debian/Ubuntu/Fedora) |
| `scripts/picom-toggle.sh` | Toggle picom compositor (bound to Ctrl+Alt+O) |
| `picom.conf` | Picom compositor config |
| `install.sh` | Dependency installer — Arch, Debian/Ubuntu, Fedora, Alpine, FreeBSD, OpenBSD |

## Submodules

| Directory | Upstream | Purpose |
|---|---|---|
| `lain/` | https://github.com/lcpz/lain | Widget library (MPD, mem, cpu, net, cal, separators) |
| `freedesktop/` | https://github.com/lcpz/awesome-freedesktop | Right-click app menu from .desktop files |
| `awesome-wm-widgets/` | https://github.com/streetturtle/awesome-wm-widgets | Weather widget (`weather-api-widget/` only used) |
| `updatewidget/` | vendored (based on raksooo/pacmanwidget, heavily modified) | Multi-distro update count — not a submodule |

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

`/etc/pacman.d/hooks/updateWidget.hook` triggers `update_widget_hook()` (an
AwesomeWM global) after package operations to refresh the update count
without waiting for the next 5-minute poll.

## Portability

Shell commands in widgets must be portable to **Linux, FreeBSD, and OpenBSD**.
Avoid GNU-specific flags and tools. Prefer POSIX equivalents:

- Use `ps -axo rss,comm | sort -rn` — not `ps --sort=` or `-e`
- Use POSIX `awk` — `printf`, field splitting, and arithmetic are fine; avoid GNU extensions
- Use `sysctl` for BSD kernel stats; guard Linux-only paths (e.g. `/proc/`) with an OS check
- ZFS ARC: `/proc/spl/kstat/zfs/arcstats` on Linux; `sysctl kstat.zfs.misc.arcstats.*` on FreeBSD
- Detect OS at startup with `io.open` path probing or a single `uname` call; avoid repeated branching

## Testing install.sh

`install.sh` supports Arch, Debian/Ubuntu, Fedora, Alpine, FreeBSD, and OpenBSD.
Package names must be verified against each distro's package manager. Use Docker
to test without installing anything:

```bash
# Check a single distro
docker run --rm -v /tmp/test-pkgs.sh:/test-pkgs.sh ubuntu:24.04 sh /test-pkgs.sh

# Run all supported Linux distros in parallel
for image in ubuntu:24.04 debian:12 archlinux:latest fedora:41 alpine:latest; do
    docker run --rm -v /tmp/test-pkgs.sh:/test-pkgs.sh "$image" sh /test-pkgs.sh &
done
wait
```

The test script `/tmp/test-pkgs.sh` auto-detects the distro, updates the package
index, and checks every package name with the native package manager query tool
(`apt-cache show`, `pacman -Si`, `dnf info`, `apk info`). It exits non-zero if
any package is not found.

**Known distro-specific notes:**
- Fedora: `mpd` requires RPM Fusion free repo (not in default repos)
- Fedora/Alpine: use `unclutter-xfixes` instead of `unclutter`
- Alpine: `xss-lock` is not available; screen locking requires a manual setup
- Arch: `xfce4-settings` (not `xfce4-settings-manager`) is the correct package name
- Debian/Ubuntu: i3lock-color is built from source via `scripts/build-i3lock-color.sh`

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

## AwesomeWM PATH vs. login PATH

AwesomeWM inherits the PATH from the X session at login time. This is a **stripped
PATH** — it does not include directories added by `~/.profile`, `~/.bashrc`, cargo,
mise, pyenv, etc. which are only sourced in interactive shells.

**Current AwesomeWM PATH** (from `awesome-client 'return os.getenv("PATH")'`):
```
~/.atuin/bin:~/.local/bin:~/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Any tool not in one of those directories will silently fail when called from
`awful.spawn.with_shell()`, widget commands, or scripts launched by keybindings.

**Known tools that need a symlink:**

| Tool | Installed at | Fix |
|---|---|---|
| `wallust` | `~/.cargo/bin/wallust` | `ln -sf ~/.cargo/bin/wallust ~/.local/bin/wallust` |

The symlink into `~/.local/bin` is the correct fix — do not hardcode full paths
in scripts or Lua, as that breaks portability and makes the config harder to maintain.

If a widget or keybinding silently does nothing, check whether the tool it calls
is visible under AwesomeWM's PATH before looking for bugs in the Lua code:

```bash
awesome-client 'return os.execute("which <tool>")'
```

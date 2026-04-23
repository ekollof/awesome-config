# contrib/

Example configurations and helper scripts to complement this AwesomeWM setup.
None of these files are used directly by AwesomeWM — copy and adapt them as needed.

## wallpaper.sh

Standalone wallpaper-changing script. Sets a wallpaper, regenerates the wallust
color palette, and restarts AwesomeWM to apply everything in one step.

```bash
# Set a specific wallpaper
bash contrib/wallpaper.sh ~/Pictures/wallpapers/my-wallpaper.jpg

# Pick a random image from ~/Pictures/wallpapers (or a custom dir)
bash contrib/wallpaper.sh random
bash contrib/wallpaper.sh random ~/Pictures/landscapes

# Re-run wallust on the current wallpaper (re-generate colors only)
bash contrib/wallpaper.sh reload
```

Install it somewhere on your `$PATH` for convenience:

```bash
cp contrib/wallpaper.sh ~/bin/wallpaper
chmod +x ~/bin/wallpaper
```

**Requirements:** `wallust`, `awesome-client` (ships with awesomewm)

## wallust/

Wallust configuration and templates. Wallust reads wallpaper images and generates
a matching 16-color palette, then writes it out to the files defined in `wallust.toml`.
AwesomeWM reads the palette from `~/.cache/wal/awesome-colors.lua` at startup.

### Setup

```bash
# Copy the config
cp contrib/wallust/wallust.toml ~/.config/wallust/wallust.toml

# Copy the templates you want to use
cp contrib/wallust/templates/awesome-colors.lua ~/.config/wallust/templates/
cp contrib/wallust/templates/colors-rofi.rasi    ~/.config/wallust/templates/
cp contrib/wallust/templates/colors-kitty.conf   ~/.config/wallust/templates/
```

Then run wallust on a wallpaper to generate the initial palette:

```bash
wallust run ~/Pictures/wallpapers/my-wallpaper.jpg
```

### wallust/wallust.toml

Minimal wallust config with only the templates relevant to this setup:

| Template | Output | Used by |
|---|---|---|
| `awesome-colors.lua` | `~/.cache/wal/awesome-colors.lua` | AwesomeWM (required) |
| `colors-rofi.rasi` | `~/.config/rofi/wallust/colors-rofi.rasi` | rofi |
| `colors-kitty.conf` | `~/.config/kitty/wallust-colors.conf` | kitty (optional) |
| `colors.sh` | `~/.cache/wal/colors.sh` | shell/fzf (optional) |
| `colors.Xresources` | `~/.cache/wal/colors.Xresources` | xrdb (optional) |

Additional templates (GTK, Hyprland, waybar, etc.) are listed but commented out.
Uncomment the ones you need.

### wallust/templates/awesome-colors.lua

The Lua palette template. Wallust fills in `{{color0}}`–`{{color15}}`, `{{background}}`,
`{{foreground}}`, `{{cursor}}`, and `{{wallpaper}}`. The output is read by
`themes/powerarrow/theme.lua` to color the wibar segments, borders, and notifications.

### wallust/templates/colors-rofi.rasi

Rofi color theme. `@import` it from your main rofi config:

```css
@import "~/.config/rofi/wallust/colors-rofi.rasi"
```

### wallust/templates/colors-kitty.conf

Kitty terminal color theme. Add to the end of `~/.config/kitty/kitty.conf`:

```
include ~/.config/kitty/wallust-colors.conf
```

Kitty reloads without restart on `kill -SIGUSR1 $(pgrep kitty)`.
Add a hook in `wallust.toml` to do this automatically:

```toml
[hooks]
kitty = "kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true"
```

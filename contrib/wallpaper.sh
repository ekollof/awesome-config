#!/usr/bin/env bash
# wallpaper.sh — set a wallpaper, regenerate wallust colors, restart AwesomeWM
#
# Usage:
#   wallpaper.sh <path/to/image>   set a specific wallpaper
#   wallpaper.sh random [dir]      pick a random image from dir (default: ~/Pictures/wallpapers)
#   wallpaper.sh reload            re-run wallust on the current wallpaper (colors only)
#
# Requirements: wallust, awesome-client (part of awesomewm)
# Optional:     feh or xwallpaper (for setting the root window background directly)
#
# AwesomeWM reads the wallpaper path from ~/.cache/wal/awesome-colors.lua and
# sets it itself via gears.wallpaper — so no separate feh/xwallpaper call is
# strictly needed. The awesome.restart() call below picks up both the new
# wallpaper and the new color palette in one shot.

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
COLORS_FILE="$HOME/.cache/wal/awesome-colors.lua"

die()  { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '==> %s\n' "$*"; }

have() { command -v "$1" &>/dev/null; }

# ── resolve wallpaper path ────────────────────────────────────────────────────

case "${1:-}" in
    random)
        dir="${2:-$WALLPAPER_DIR}"
        [[ -d "$dir" ]] || die "wallpaper directory not found: $dir"
        # Find image files, pick one at random (POSIX-portable shuf fallback)
        mapfile -d '' images < <(find "$dir" -type f \( \
            -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
            -o -iname '*.webp' -o -iname '*.tiff' \
        \) -print0 2>/dev/null)
        [[ ${#images[@]} -gt 0 ]] || die "no images found in $dir"
        WALLPAPER="${images[RANDOM % ${#images[@]}]}"
        info "Selected: $WALLPAPER"
        ;;
    reload)
        # Re-run wallust on whatever was last used
        [[ -f "$COLORS_FILE" ]] || die "no existing colors file at $COLORS_FILE — run with a wallpaper path first"
        WALLPAPER=$(lua -e "
            local t = dofile('$COLORS_FILE')
            print(t.wallpaper)
        " 2>/dev/null) || die "could not read wallpaper path from $COLORS_FILE"
        [[ -f "$WALLPAPER" ]] || die "wallpaper no longer exists: $WALLPAPER"
        info "Reloading: $WALLPAPER"
        ;;
    ""|--help|-h)
        sed -n '2,/^$/p' "$0" | grep '^#' | sed 's/^# \?//'
        exit 0
        ;;
    *)
        WALLPAPER="$1"
        [[ -f "$WALLPAPER" ]] || die "file not found: $WALLPAPER"
        ;;
esac

# ── run wallust ───────────────────────────────────────────────────────────────

have wallust || die "wallust is not installed (see https://codeberg.org/explosion-mental/wallust)"

info "Running wallust..."
wallust run "$WALLPAPER"

# ── reload AwesomeWM ──────────────────────────────────────────────────────────

if have awesome-client; then
    info "Restarting AwesomeWM..."
    echo 'awesome.restart()' | awesome-client
else
    info "awesome-client not found — restart AwesomeWM manually (Super+Shift+R)"
fi

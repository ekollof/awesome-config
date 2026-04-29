#!/usr/bin/env bash
# install.sh — dependency installer for this AwesomeWM config
# Supports: Arch Linux, Debian/Ubuntu/Mint, FreeBSD, OpenBSD
# Usage: bash install.sh [--dry-run]

set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# ── helpers ────────────────────────────────────────────────────────────────────

info()  { printf '\033[1;34m==> \033[0m%s\n' "$*"; }
warn()  { printf '\033[1;33m[!] \033[0m%s\n' "$*"; }
ok()    { printf '\033[1;32m[✓] \033[0m%s\n' "$*"; }
skip()  { printf '\033[0;90m[-] skip: %s\n\033[0m' "$*"; }

run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        printf '\033[0;90m    (dry) %s\033[0m\n' "$*"
    else
        "$@"
    fi
}

have() { command -v "$1" &>/dev/null; }

# ── detect OS ──────────────────────────────────────────────────────────────────

OS=""
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    case "${ID:-}" in
        arch|cachyos|endeavouros|garuda) OS=arch ;;
        debian)                          OS=debian ;;
        ubuntu|linuxmint|pop)            OS=ubuntu ;;
        fedora|rhel|centos)              OS=fedora ;;
        alpine)                          OS=alpine ;;
        *)
            case "${ID_LIKE:-}" in
                *arch*)            OS=arch ;;
                *debian*|*ubuntu*) OS=ubuntu ;;
                *fedora*|*rhel*)   OS=fedora ;;
            esac
            ;;
    esac
fi

if [[ -z "$OS" ]]; then
    case "$(uname -s)" in
        FreeBSD) OS=freebsd ;;
        OpenBSD) OS=openbsd ;;
    esac
fi

[[ -z "$OS" ]] && { warn "Unsupported OS — cannot detect package manager."; exit 1; }
info "Detected OS profile: $OS"

# ── package install wrappers ───────────────────────────────────────────────────

pkg_install_arch() {
    local missing=()
    for p in "$@"; do
        pacman -Qi "$p" &>/dev/null || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "pacman -S ${missing[*]}"
    run sudo pacman -S --needed --noconfirm "${missing[@]}"
}

# Requires an AUR helper (yay preferred, falls back to paru)
aur_helper=""
pkg_install_aur() {
    if [[ -z "$aur_helper" ]]; then
        if   have yay;  then aur_helper=yay
        elif have paru; then aur_helper=paru
        else
            warn "No AUR helper found (yay/paru). Skipping AUR packages: $*"
            return
        fi
    fi
    local missing=()
    for p in "$@"; do
        pacman -Qi "$p" &>/dev/null || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "$aur_helper -S ${missing[*]}"
    run "$aur_helper" -S --needed --noconfirm "${missing[@]}"
}

pkg_install_apt() {
    local missing=()
    for p in "$@"; do
        dpkg -l "$p" 2>/dev/null | grep -q '^ii' || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "apt install ${missing[*]}"
    run sudo apt-get install -y "${missing[@]}"
}

pkg_install_freebsd() {
    local missing=()
    for p in "$@"; do
        pkg info -q "$p" 2>/dev/null || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "pkg install ${missing[*]}"
    run sudo pkg install -y "${missing[@]}"
}

pkg_install_dnf() {
    local missing=()
    for p in "$@"; do
        rpm -q "$p" &>/dev/null || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "dnf install ${missing[*]}"
    run sudo dnf install -y "${missing[@]}"
}

pkg_install_apk() {
    local missing=()
    for p in "$@"; do
        apk info -e "$p" &>/dev/null || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "apk add ${missing[*]}"
    run sudo apk add "${missing[@]}"
}

pkg_install_openbsd() {
    # pkg_info -q returns 0 if installed
    local missing=()
    for p in "$@"; do
        pkg_info -q "$p" 2>/dev/null || missing+=("$p")
    done
    [[ ${#missing[@]} -eq 0 ]] && return
    info "pkg_add ${missing[*]}"
    run sudo pkg_add "${missing[@]}"
}

install_pkgs() {
    # install_pkgs arch_pkg... --- apt_pkg... --- freebsd_pkg... --- openbsd_pkg... --- fedora_pkg... --- alpine_pkg...
    # Use "SKIP" as a placeholder for a section if not applicable
    local arch=() apt=() freebsd=() openbsd=() fedora=() alpine=()
    local section=0
    for arg in "$@"; do
        if [[ "$arg" == "---" ]]; then
            (( section++ )) || true
        else
            case $section in
                0) arch+=("$arg") ;;
                1) apt+=("$arg") ;;
                2) freebsd+=("$arg") ;;
                3) openbsd+=("$arg") ;;
                4) fedora+=("$arg") ;;
                5) alpine+=("$arg") ;;
            esac
        fi
    done
    case "$OS" in
        arch)
            [[ ${#arch[@]} -gt 0 && "${arch[0]}" != "SKIP" ]] && pkg_install_arch "${arch[@]}" ;;
        debian|ubuntu)
            [[ ${#apt[@]} -gt 0 && "${apt[0]}" != "SKIP" ]] && pkg_install_apt "${apt[@]}" ;;
        freebsd)
            [[ ${#freebsd[@]} -gt 0 && "${freebsd[0]}" != "SKIP" ]] && pkg_install_freebsd "${freebsd[@]}" ;;
        openbsd)
            [[ ${#openbsd[@]} -gt 0 && "${openbsd[0]}" != "SKIP" ]] && pkg_install_openbsd "${openbsd[@]}" ;;
        fedora)
            [[ ${#fedora[@]} -gt 0 && "${fedora[0]}" != "SKIP" ]] && pkg_install_dnf "${fedora[@]}" ;;
        alpine)
            [[ ${#alpine[@]} -gt 0 && "${alpine[0]}" != "SKIP" ]] && pkg_install_apk "${alpine[@]}" ;;
    esac
}

# ── submodules ─────────────────────────────────────────────────────────────────

info "Initialising git submodules (freedesktop)..."
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$REPO_DIR/.gitmodules" ]]; then
    run git -C "$REPO_DIR" submodule update --init --recursive
else
    warn "Not a git repo or no .gitmodules — skipping submodule init"
fi

# ── packages ───────────────────────────────────────────────────────────────────

info "Installing core packages..."

# AwesomeWM
install_pkgs \
    awesome --- \
    awesome --- \
    x11/awesome --- \
    awesome --- \
    awesome --- \
    awesome

# Compositor
install_pkgs \
    picom --- \
    picom --- \
    x11/picom --- \
    picom --- \
    picom --- \
    picom

# Terminal
install_pkgs \
    kitty --- \
    kitty --- \
    x11/kitty --- \
    kitty --- \
    kitty --- \
    kitty

# Audio
install_pkgs \
    alsa-utils libpulse pavucontrol --- \
    alsa-utils libpulse-dev pavucontrol --- \
    audio/alsa-utils audio/pavucontrol --- \
    alsa-utils pavucontrol --- \
    alsa-utils pulseaudio-libs pavucontrol --- \
    alsa-utils pulseaudio pavucontrol

# MPD stack
# On Fedora, mpd is in RPM Fusion free — enabled automatically below if needed.
install_pkgs \
    mpd mpc ncmpcpp --- \
    mpd mpc ncmpcpp --- \
    audio/mpd audio/mpc audio/ncmpcpp --- \
    mpd mpc ncmpcpp --- \
    mpd mpc ncmpcpp --- \
    mpd mpc ncmpcpp

if [[ "$OS" == "fedora" ]]; then
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        info "Enabling RPM Fusion free repo (required for mpd)..."
        FEDORA_VER=$(rpm -E %fedora)
        run sudo dnf install -y \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm"
    else
        ok "RPM Fusion free repo already enabled."
    fi
    # Now install mpd (may have been skipped above if repo wasn't present yet)
    pkg_install_dnf mpd mpc ncmpcpp
fi

# File manager
install_pkgs \
    thunar --- \
    thunar --- \
    x11/thunar --- \
    thunar --- \
    thunar --- \
    thunar

# Launchers
install_pkgs \
    rofi dmenu --- \
    rofi dmenu --- \
    x11/rofi x11/dmenu --- \
    rofi dmenu --- \
    rofi dmenu --- \
    rofi dmenu

# Xfce utilities
install_pkgs \
    xfce4-terminal xfce4-taskmanager xfce4-appfinder xfce4-screenshooter xfce4-settings --- \
    xfce4-terminal xfce4-taskmanager xfce4-appfinder xfce4-screenshooter xfce4-settings --- \
    x11/xfce4-terminal x11/xfce4-taskmanager x11/xfce4-appfinder x11/xfce4-screenshooter x11/xfce4-settings-manager --- \
    xfce4-terminal xfce4-taskmanager xfce4-appfinder xfce4-screenshooter xfce4-settings-manager --- \
    xfce4-terminal xfce4-taskmanager xfce4-appfinder xfce4-screenshooter xfce4-settings --- \
    xfce4-terminal xfce4-taskmanager xfce4-appfinder xfce4-screenshooter xfce4-settings

# X11 utilities
install_pkgs \
    xorg-xkill xorg-xbacklight xorg-xprop xorg-xwininfo xorg-xev --- \
    x11-utils x11-xserver-utils --- \
    x11/xkill x11/xbacklight x11/xprop x11/xwininfo x11/xev --- \
    xkill xbacklight xprop xwininfo xev --- \
    xkill xbacklight xprop xwininfo xev --- \
    xkill xbacklight xprop xwininfo

# System utilities
# Note: 'unclutter' is replaced by 'unclutter-xfixes' on Fedora and Alpine
install_pkgs \
    scrot unclutter curl arandr --- \
    scrot unclutter curl arandr --- \
    graphics/scrot x11/unclutter ftp/curl x11/arandr --- \
    scrot unclutter curl arandr --- \
    scrot unclutter-xfixes curl arandr --- \
    scrot unclutter-xfixes curl arandr

# Password manager
install_pkgs \
    pass --- \
    pass --- \
    security/pass --- \
    pass --- \
    pass --- \
    pass

# Lua GObject introspection (for in-memory cover art decode)
install_pkgs \
    lua-lgi --- \
    lua-lgi --- \
    devel/lua-lgi --- \
    lua-lgi --- \
    lua-lgi --- \
    lua-lgi

# Python MaxMind DB reader (for local GeoLite2 location lookup)
install_pkgs \
    python-maxminddb python-geoip2 --- \
    python3-maxminddb python3-geoip2 --- \
    py38-maxminddb py38-geoip2 --- \
    py3-maxminddb py3-geoip2 --- \
    python3-maxminddb python3-geoip2 --- \
    py3-maxminddb py3-geoip2

# xss-lock — hooks xscreensaver idle timer to run the lock script
install_pkgs \
    xss-lock --- \
    xss-lock --- \
    SKIP --- \
    SKIP --- \
    xss-lock --- \
    SKIP

# ── i3lock-color (screen locker) ───────────────────────────────────────────────

info "Checking for i3lock-color..."

if i3lock --version 2>&1 | grep -q "i3lock-color"; then
    ok "i3lock-color already installed ($(i3lock --version 2>&1 | head -1))."
else
    case "$OS" in
        arch)
            info "Installing i3lock-color from AUR..."
            pkg_install_aur i3lock-color
            ;;
        debian|ubuntu)
            # Not available in apt — build from source using the bundled script.
            info "i3lock-color not found. Building from source..."
            if [[ $DRY_RUN -eq 1 ]]; then
                printf '    (dry) bash %s/scripts/build-i3lock-color.sh\n' "$REPO_DIR"
            else
                bash "$REPO_DIR/scripts/build-i3lock-color.sh"
            fi
            ;;
        freebsd|openbsd|alpine)
            warn "i3lock-color: no package available for $OS — build manually from source."
            warn "  See: https://github.com/Raymo111/i3lock-color"
            ;;
        fedora)
            # Not in default Fedora repos — build from source using the bundled script.
            info "i3lock-color not found. Building from source..."
            if [[ $DRY_RUN -eq 1 ]]; then
                printf '    (dry) bash %s/scripts/build-i3lock-color.sh\n' "$REPO_DIR"
            else
                bash "$REPO_DIR/scripts/build-i3lock-color.sh"
            fi
            ;;
    esac
fi

# Pacman update checking (Arch only)
if [[ "$OS" == "arch" ]]; then
    info "Installing pacman-contrib (checkupdates)..."
    pkg_install_arch pacman-contrib
fi

# ── AUR packages (Arch only) ───────────────────────────────────────────────────

if [[ "$OS" == "arch" ]]; then
    info "Installing AUR packages..."

    # yay itself — bootstrap if missing
    if ! have yay && ! have paru; then
        warn "No AUR helper found. Attempting to bootstrap yay..."
        if have git && have makepkg; then
            TMPDIR=$(mktemp -d)
            run git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$TMPDIR/yay-bin"
            run bash -c "cd '$TMPDIR/yay-bin' && makepkg -si --noconfirm"
            rm -rf "$TMPDIR"
            aur_helper=yay
        else
            warn "git or makepkg missing — cannot bootstrap yay. Install an AUR helper manually."
        fi
    fi

    # Brave browser
    aur_install_note() { warn "AUR: $1 — install manually if aur_helper is unavailable"; }
    pkg_install_aur brave-bin

    # Wallust (pywal-compatible color scheme generator)
    pkg_install_aur wallust
fi

# ── Nerd Fonts ─────────────────────────────────────────────────────────────────

info "Checking fonts..."

# BerkeleyMono Nerd Font is a commercial font — we can't auto-install it.
# Check if any variant is present and warn if not.
if fc-list 2>/dev/null | grep -qi "berkeleymono"; then
    ok "BerkeleyMono Nerd Font found."
else
    warn "BerkeleyMono Nerd Font not found."
    warn "This config uses 'BerkeleyMono Nerd Font' (theme.lua:31)."
    warn "It is a commercial font. Purchase and install from:"
    warn "  https://berkeleygraphics.com/typefaces/berkeley-mono/"
    warn "Then patch with a Nerd Font patcher or download a pre-patched variant."
    warn "As a fallback, any Nerd Font monospace will work — e.g. JetBrainsMono Nerd Font."
fi

# Nerd Font symbols (needed for updatewidget glyph U+F0416)
case "$OS" in
    arch)
        pkg_install_aur ttf-nerd-fonts-symbols-mono 2>/dev/null || \
        pkg_install_arch ttf-nerd-fonts-symbols 2>/dev/null || true ;;
    debian|ubuntu)
        # Not in apt — advise manual install
        if ! fc-list 2>/dev/null | grep -qi "nerd"; then
            warn "No Nerd Font found. Install one for the pacman widget glyph (󰏖)."
            warn "  https://www.nerdfonts.com/font-downloads"
        fi ;;
esac

# Refresh font cache
if have fc-cache; then
    info "Refreshing font cache..."
    run fc-cache -f
fi

# ── wallust colour template ────────────────────────────────────────────────────

WALLUST_TEMPLATE_DIR="$HOME/.config/wallust/templates"
WALLUST_COLORS_SRC="$REPO_DIR/themes/powerarrow/awesome-colors.lua.template"
WALLUST_COLORS_DST="$HOME/.cache/wal/awesome-colors.lua"

if [[ -f "$WALLUST_COLORS_SRC" ]]; then
    info "Installing wallust template..."
    run mkdir -p "$WALLUST_TEMPLATE_DIR"
    run cp -v "$WALLUST_COLORS_SRC" "$WALLUST_TEMPLATE_DIR/awesome-colors.lua"
fi

# Create a default colors file so awesome starts without wallust having run yet
if [[ ! -f "$WALLUST_COLORS_DST" ]]; then
    info "Creating placeholder wallust colors file..."
    run mkdir -p "$(dirname "$WALLUST_COLORS_DST")"
    if [[ $DRY_RUN -eq 0 ]]; then
        cat > "$WALLUST_COLORS_DST" <<'EOF'
-- Placeholder generated by install.sh
-- Run: wallust run <wallpaper> to generate real colors
return {
    wallpaper = nil,
    color0  = "#1e1e2e", color1  = "#f38ba8", color2  = "#a6e3a1",
    color3  = "#f9e2af", color4  = "#89b4fa", color5  = "#cba4f7",
    color6  = "#94e2d5", color7  = "#cdd6f4", color8  = "#585b70",
    color9  = "#f38ba8", color10 = "#a6e3a1", color11 = "#f9e2af",
    color12 = "#89b4fa", color13 = "#cba4f7", color14 = "#94e2d5",
    color15 = "#cdd6f4",
    background = "#1e1e2e", foreground = "#cdd6f4",
}
EOF
    fi
fi

# ── picom hook ─────────────────────────────────────────────────────────────────

if [[ "$OS" == "arch" ]]; then
    HOOK_DIR="/etc/pacman.d/hooks"
    HOOK_FILE="$HOOK_DIR/updateWidget.hook"
    if [[ ! -f "$HOOK_FILE" ]]; then
        info "Installing pacman hook for updatewidget..."
        run sudo mkdir -p "$HOOK_DIR"
        if [[ $DRY_RUN -eq 0 ]]; then
            sudo tee "$HOOK_FILE" > /dev/null <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Notifying AwesomeWM pacman widget...
When = PostTransaction
Exec = /bin/sh -c 'echo "update_widget_hook()" | awesome-client 2>/dev/null || true'
EOF
        else
            printf '    (dry) write %s\n' "$HOOK_FILE"
        fi
        ok "Pacman hook installed."
    else
        ok "Pacman hook already present."
    fi
fi

# ── MPD user service ───────────────────────────────────────────────────────────

if [[ "$OS" == "arch" || "$OS" == "debian" || "$OS" == "ubuntu" ]]; then
    if have systemctl; then
        if systemctl --user is-enabled mpd &>/dev/null; then
            ok "MPD user service already enabled."
        else
            info "Enabling MPD user service..."
            run systemctl --user enable --now mpd
        fi
    fi
fi

# ── done ───────────────────────────────────────────────────────────────────────

echo ""
ok "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Install BerkeleyMono Nerd Font (or set a different font in themes/powerarrow/theme.lua)"
echo "  2. Set up MPD: edit ~/.config/mpd/mpd.conf with your music directory"
echo "  3. Set up weather: store your weatherapi.com key with:"
echo "       pass insert api/weatherapi.com/key"
echo "  4. Run wallust to generate colors:"
echo "       wallust run /path/to/wallpaper.jpg"
echo "  5. Start or restart AwesomeWM"

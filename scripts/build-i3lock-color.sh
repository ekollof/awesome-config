#!/bin/bash
# Build and install i3lock-color from source.
# Run once; re-run to upgrade to a newer version.
set -e

VERSION="2.13.c.5"
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

echo "==> Installing build dependencies..."
sudo apt-get install -y \
    autoconf automake pkg-config \
    libxcb1-dev libxcb-util0-dev libxcb-xinerama0-dev \
    libxcb-composite0-dev libxcb-image0-dev libxcb-randr0-dev \
    libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
    libev-dev libpam0g-dev libcairo2-dev libjpeg-dev \
    libxrandr-dev

echo "==> Cloning i3lock-color $VERSION..."
git clone --depth 1 --branch "$VERSION" \
    https://github.com/Raymo111/i3lock-color.git "$BUILD_DIR/i3lock-color"

echo "==> Building..."
cd "$BUILD_DIR/i3lock-color"
./install-i3lock-color.sh

echo "==> Done. i3lock-color installed to $(which i3lock-color)"

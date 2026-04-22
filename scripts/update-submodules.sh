#!/usr/bin/env bash
# Update all git submodules to their latest upstream commit

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

cd "$REPO"

git submodule foreach 'echo "==> Updating $name..." && git pull origin HEAD'

echo ""
echo "Done. Staging updated submodule refs..."
git add lain freedesktop awesome-wm-widgets
git status --short
echo ""
echo "Run 'git commit' to record the new submodule refs."

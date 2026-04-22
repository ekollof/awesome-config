#!/usr/bin/env bash
# Update all git submodules to latest upstream on their tracked branch

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

cd "$REPO"

git submodule foreach '
  branch=$(git config -f "$toplevel/.gitmodules" "submodule.$name.branch")
  branch=${branch:-master}
  echo "==> $name: switching to $branch and pulling..."
  git checkout "$branch"
  git pull origin "$branch"
'

echo ""
echo "Done. Staging updated submodule refs..."
git add lain freedesktop awesome-wm-widgets
git status --short
echo ""
echo "Run 'git commit' to record the new submodule refs."

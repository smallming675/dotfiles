#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

host="${1:-desktop}"

echo "Formatting Nix files..."
alejandra . >/dev/null

echo "Diff (nix files):"
git diff -U0 -- '*.nix'

git add flake.nix flake.lock rebuild.sh hosts/ modules/ configuration.nix hardware-configuration.nix home.nix

echo "Rebuilding host: ${host}"
sudo nixos-rebuild switch --flake "${REPO_DIR}#${host}"

current_gen="$(nixos-rebuild list-generations | awk '/current/ {print $1; exit}')"
msg="nixos(${host}): switch to generation ${current_gen}"

if git diff --cached --quiet; then
  echo "No staged changes to commit."
else
  git commit -m "$msg"
fi

echo "Rebuild success for ${host}."

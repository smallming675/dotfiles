#!/usr/bin/env bash
set -e

host="${1:-desktop}"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

sudo nixos-rebuild switch --flake "${REPO_DIR}#${host}"
current=$(nixos-rebuild list-generations | awk '$NF=="True" {print $1, $2, $3}')

git commit -am "$current"

echo "Rebuild success!"

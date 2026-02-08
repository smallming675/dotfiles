#!/usr/bin/env bash
set -e

host="desktop"
commit_only=false

for arg in "$@"; do
  case "$arg" in
    --commit)
      commit_only=true
      ;;
    *)
      host="$arg"
      ;;
  esac
done

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

git diff -U0 '*.nix'

if [ "$commit_only" = true ]; then
  git commit -am "manual config update"
  echo "Commit success (no rebuild)."
  exit 0
fi

echo "NixOS Rebuilding..."

sudo nixos-rebuild switch --flake "${REPO_DIR}#${host}"
current=$(nixos-rebuild list-generations | awk '$NF=="True" {print $1, $2, $3}')

git commit -am "$current"

echo "Rebuild success!"

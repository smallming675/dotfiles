#!/usr/bin/env bash
set -e

alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

sudo nixos-rebuild switch --flake $HOME/config#nixos 
current=$(nixos-rebuild list-generations | awk '$NF=="True" {print $1, $2, $3}')

git commit -am "$current"

echo "Rebuild success!"

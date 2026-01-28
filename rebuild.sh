#!/usr/bin/env bash
set -e

alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

nh os switch $HOME/config -H nixos &> nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)
current=$(nixos-rebuild list-generations | awk '$NF=="True" {print $1, $2, $3}')

git commit -am "$current"

echo "Rebuild success!"
rm nixos-switch.log
popd



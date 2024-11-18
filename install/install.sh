#!/bin/env bash

cd ~/dotfiles/
sudo pacman -Syu
pacman -S - < .pkglist.txt
stow .

#!/bin/env bash
sudo pacman -Syu 
yay -Syu 
sudo paccache -r
sudo pacman -Qtdq | sudo pacman -Rns -
sudo pacman -Rns $(pacman -Qdtq)
rm -rf ~/.cache/*



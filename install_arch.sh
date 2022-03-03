#!/bin/bash

cd /tmp/
sudo pacman -Syyu
sudo pacman -S sudo bspwm sxhkd zsh cmake gcc \
  llvm npm yarn rofi ranger neovim thunar python \
  feh nitrogen vscodium wget curl xorg xinit firefox neofetch \
  ninja discord dunst picom scrot alacritty

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -S betterlockscreen polybar consolas-font powerkit

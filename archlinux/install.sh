#!/bin/bash

cd /tmp/
sudo pacman -Syyu
sudo pacman -S bspwm sxhkd zsh cmake gcc rofi ranger neovim thunar \
  feh nitrogen wget curl xorg xinit firefox neofetch ninja dunst alacritty \
  picom scrot docker polybar xdg-user-dirs base-devel libxrandr thunar-volman \
  gvfs openssl vlc upower pavucontrol xfce4-settings

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
#yay -S betterlockscreen polybar consolas-font powerkit

cp .zshrc ~/

yay -S catppuccin-gtk-theme-mocha catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte

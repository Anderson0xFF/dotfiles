#!/bin/bash

cp .zshrc ~/
cd /tmp/
sudo pacman -Syyu
sudo pacman -S bspwm sxhkd zsh cmake gcc rofi ranger neovim thunar \
  feh nitrogen wget curl xorg xorg-xinit firefox neofetch ninja dunst alacritty \
  picom scrot docker polybar xdg-user-dirs base-devel libxrandr thunar-volman \
  gvfs openssl vlc upower pavucontrol xfce4-settings tmux exa bat


sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber helvum
sudo systemctl --user enable --now pipewire.socket
sudo systemctl --user enable --now pipewire-pulse.socket
sudo systemctl --user enable --now wireplumber.service

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

xdg-user-dirs-update



yay -S catppuccin-gtk-theme-mocha catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte

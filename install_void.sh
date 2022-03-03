#!/bin/bash
sudo xbps-install -Su
sudo xbps-install void-repo-nonfree
sudo xbps-install -Suv
sudo xbps-install -S bspwm sxhkd zsh cmake gcc \
	llvm rofi ranger neovim Thunar python \
	feh nitrogen wget vscode curl xorg xinit firefox \
	neofetch ninja dunst alacritty scrot picom polybar
	betterlockscreen

echo "Install powerkit"
cd /tmp/
git clone https://github.com/rodlie/powerkit
cd powerkit
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release ..
make
make DESTDIR=<package> install

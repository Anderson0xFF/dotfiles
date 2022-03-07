#!/bin/bash

sudo xbps-install -Su
sudo xbps-install void-repo-nonfree
sudo xbps-install -Suv
sudo xbps-install -S bspwm sxhkd zsh cmake gcc \
	llvm rofi ranger neovim Thunar python \
	feh nitrogen wget vscode curl xorg xinit firefox \
	neofetch ninja dunst alacritty scrot picom polybar \
	betterlockscreen xdg-user-dirs base-devel libXrandr-devel \
	upower libXScrnSaver-devel qt5-devel

echo "Directory update"
xdg-user-dirs-update

echo "Install powerkit"
cd $HOME
git clone https://github.com/rodlie/powerkit
cd powerkit
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install
